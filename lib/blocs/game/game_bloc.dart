import 'dart:math';

import 'package:deepfake_detector/constants/overlay_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/video_repository.dart';
import '../../repositories/statistics_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/internal_statistics_repository.dart';

import '../../models/statistics_model.dart';
import '../../exceptions/app_exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final VideoRepository _videoRepository;
  final StatisticsRepository _statisticsRepository;
  final UserRepository _userRepository;
  final InternalStatisticsRepository _internalStatsRepository;

  GameBloc({
    required VideoRepository videoRepository,
    required StatisticsRepository statisticsRepository,
    required UserRepository userRepository,
    required InternalStatisticsRepository internalStatsRepository,
  })  : _videoRepository = videoRepository,
        _statisticsRepository = statisticsRepository,
        _userRepository = userRepository,
        _internalStatsRepository = internalStatsRepository,
        super(const GameState.initial()) {
    on<QuickStartGame>(_onQuickStartGame);
    on<LoginWithPin>(_onLoginWithPin);
    on<ShowLogin>(_onShowLogin);
    on<CancelLogin>(_onCancelLogin);
    on<NextScreen>(_onNextScreen);
    on<PreviousScreen>(_onPreviousScreen);
    on<RestartGame>(_onRestartGame);
    on<GeneratePin>(_onGeneratePin);
    on<CheckPin>(_onCheckPin);
    on<InitializeGame>(_onInitializeGame);
    on<UpdateSelectedVideo>(_onUpdateSelectedVideo);
    on<StrategyIndexChanged>(_onStrategyIndexChanged);
    on<ChangeLanguage>(_onChangeLanguage);
    on<MakeDeepfakeDecision>(_onMakeDeepfakeDecision);
    on<OverlayCompleted>(_onOverlayCompleted);
    on<SetInitialConfidenceRating>(_onSetInitialConfidenceRating);
    on<SurveyCompleted>(_onSurveyCompleted);
  }

  Future<void> _onQuickStartGame(
      QuickStartGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      final playerId = _generatePlayerId();
      final videos = await _videoRepository.getRandomVideoPair({});
      final totalUniquePairs =
          await _videoRepository.getTotalUniqueVideoPairs();

      // Record start of new game in internal statistics
      await _internalStatsRepository.recordGameStart(playerId);

      // Prüfen, ob die Umfrage angezeigt werden soll
      final shouldShowSurvey =
          !state.hasOverlayBeenShown(OverlayType.confidenceSurvey);

      // Wenn die Umfrage angezeigt werden soll, gehe in einen speziellen Status
      if (shouldShowSurvey) {
        emit(state.copyWith(
          status: GameStatus.waitingForSurvey,
          currentScreen: GameScreen.introduction,
          currentPin: null,
          videos: videos,
          userStatistics: UserStatistics.temporary(),
          errorMessage: null,
          playerId: playerId,
          totalUniquePairs: totalUniquePairs,
        ));
      } else {
        // Normaler Ablauf, wenn keine Umfrage gezeigt werden soll
        emit(state.copyWith(
          status: GameStatus.playing,
          currentScreen: GameScreen.firstVideo,
          currentPin: null,
          videos: videos,
          userStatistics: UserStatistics.temporary(),
          errorMessage: null,
          playerId: playerId,
          totalUniquePairs: totalUniquePairs,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to start game: $e',
      ));
    }
  }

  Future<void> _onLoginWithPin(
      LoginWithPin event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      final user = await _userRepository.getUserByPin(event.pin);
      if (user == null) {
        emit(state.copyWith(
          status: GameStatus.loginError,
          errorMessage: 'Invalid PIN',
          currentScreen: GameScreen.login,
        ));
        return;
      }

      await _internalStatsRepository.recordPinLogin(event.pin.toString());
      await _internalStatsRepository.recordGameStart(event.pin.toString());

      // Get existing statistics and create new instance with empty recentAttempts
      final existingStats =
          await _statisticsRepository.getStatistics(event.pin);
      final videos =
          await _videoRepository.getRandomVideoPair(existingStats.seenPairIds);
      final totalUniquePairs =
          await _videoRepository.getTotalUniqueVideoPairs();

      final statistics = existingStats.copyWith(recentAttempts: []);
      await _statisticsRepository.resetRecentAttempts(event.pin);
      final locale = existingStats.locale;

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        currentPin: event.pin,
        userStatistics: statistics,
        videos: videos,
        errorMessage: null,
        playerId: event.pin.toString(),
        locale: locale,
        totalUniquePairs: totalUniquePairs,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onGeneratePin(
      GeneratePin event, Emitter<GameState> emit) async {
    try {
      final pin = await _userRepository.createNewUser();

      // Update internal statistics to mark pin registration
      if (state.playerId != null) {
        await _internalStatsRepository.recordPinRegistration(
          state.playerId!,
          pin.toString(),
        );
      }

      // Convert temporary statistics if available
      if (state.userStatistics != null && state.userStatistics!.isTemporary) {
        final permanentStats =
            await _statisticsRepository.convertTemporaryStats(
          state.userStatistics!,
          pin,
        );

        emit(state.copyWith(
          currentPin: pin,
          userStatistics: permanentStats,
          status: GameStatus.playing,
          playerId: pin.toString(),
        ));
      } else {
        final newStats = UserStatistics.withPin(pin);
        emit(state.copyWith(
          currentPin: pin,
          userStatistics: newStats,
          status: GameStatus.playing,
          playerId: pin.toString(),
        ));
      }

      if (event.onPinGenerated != null) {
        event.onPinGenerated!(pin.toString());
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to generate PIN: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMakeDeepfakeDecision(
      MakeDeepfakeDecision event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing ||
        state.currentScreen != GameScreen.decision ||
        state.videos.isEmpty) {
      return;
    }

    final currentVideo = state.videos.first;
    final isCorrect = event.isDeepfake == currentVideo.isDeepfake;

    try {
      final attempt = GameAttempt(
        timestamp: DateTime.now(),
        wasCorrect: isCorrect,
        videoIds: state.videos.map((video) => video.id).toList(),
        userGuessIsDeepfake: event.isDeepfake,
        pairId: currentVideo.pairId,
      );

      // Aktualisiere Statistiken basierend auf PIN-Status
      final updatedStats = await _statisticsRepository.addAttempt(
        attempt,
        pin: state.currentPin,
        stats: state.userStatistics,
      );

      // Update internal statistics
      await _internalStatsRepository.recordGameAttempt(
        playerId: state.playerId!,
        wasCorrect: isCorrect,
        hasPinRegistered: state.currentPin != null,
      );

      emit(state.copyWith(
        userGuessIsDeepfake: event.isDeepfake,
        isCorrectGuess: isCorrect,
        userStatistics: updatedStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to record attempt: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRestartGame(
      RestartGame event, Emitter<GameState> emit) async {
    final currentPin = state.currentPin;
    final currentStats = state.userStatistics;

    emit(state.copyWith(status: GameStatus.loading));

    try {
      await _internalStatsRepository.recordGameStart(state.playerId!);
      UserStatistics? statistics;

      if (currentPin != null) {
        // Lade permanente Statistiken
        statistics = await _statisticsRepository.getStatistics(currentPin);
      } else if (currentStats != null && currentStats.isTemporary) {
        // Behalte existierende temporäre Statistiken
        statistics = currentStats;
      } else {
        // Erstelle neue temporäre Statistiken nur wenn keine existieren
        statistics = UserStatistics.temporary();
      }

      final videos =
          await _videoRepository.getRandomVideoPair(statistics.seenPairIds);
      final totalUniquePairs =
          await _videoRepository.getTotalUniqueVideoPairs();

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        videos: videos,
        userStatistics: statistics,
        userGuessIsDeepfake: null,
        isCorrectGuess: null,
        errorMessage: null,
        generatedPin: null,
        totalUniquePairs: totalUniquePairs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to restart game: ${e.toString()}',
      ));
    }
  }

  Future<void> _onShowLogin(ShowLogin event, Emitter<GameState> emit) async {
    emit(state.copyWith(
      status: GameStatus.showLogin,
      currentScreen: GameScreen.login,
    ));
  }

  Future<void> _onCancelLogin(
      CancelLogin event, Emitter<GameState> emit) async {
    emit(state.copyWith(
      status: GameStatus.initial,
      currentScreen: GameScreen.introduction,
    ));
  }

  Future<void> _onCheckPin(CheckPin event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final user = await _userRepository.getUserByPin(event.pin);
      if (user != null) {
        add(LoginWithPin(event.pin));
      } else {
        emit(state.copyWith(
            errorMessage: 'Invalid PIN', status: GameStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to check PIN: ${e.toString()}',
      ));
    }
  }

  Future<void> _onNextScreen(NextScreen event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing || state.videos.isEmpty) return;

    switch (state.currentScreen) {
      case GameScreen.introduction:
        emit(state.copyWith(currentScreen: GameScreen.firstVideo));
        break;

      case GameScreen.firstVideo:
        emit(state.copyWith(currentScreen: GameScreen.decision));
        break;

      case GameScreen.decision:
        if (state.userGuessIsDeepfake != null) {
          emit(state.copyWith(currentScreen: GameScreen.result));
        }
        break;

      case GameScreen.result:
        try {
          if (state.playerId != null) {
            await _internalStatsRepository.recordGameCompletion(
              playerId: state.playerId!,
              completedFullGame: true,
              hasPinRegistered: state.currentPin != null,
            );

            // Aktualisiere die Statistiken vor dem Screen-Wechsel
            if (state.userStatistics != null) {
              UserStatistics updatedStats;
              if (state.currentPin != null) {
                updatedStats = await _statisticsRepository
                    .getStatistics(state.currentPin!);
              } else {
                // Für temporäre Nutzer behalten wir die existierenden Statistiken
                updatedStats = state.userStatistics!;
              }
              emit(state.copyWith(
                  userStatistics: updatedStats,
                  currentScreen: GameScreen.strategy));
            } else {
              emit(state.copyWith(currentScreen: GameScreen.strategy));
            }
          } else {
            emit(state.copyWith(currentScreen: GameScreen.strategy));
          }
        } catch (e) {
          emit(state.copyWith(
            status: GameStatus.error,
            errorMessage: 'Failed to update statistics: $e',
          ));
        }
        break;

      case GameScreen.strategy:
        emit(state.copyWith(currentScreen: GameScreen.statistics));
        break;
      case GameScreen.statistics:
        add(const RestartGame());
        break;
      default:
        break;
    }
  }

  Future<void> _onPreviousScreen(
      PreviousScreen event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing) return;

    GameScreen previousScreen;
    switch (state.currentScreen) {
      case GameScreen.decision:
        previousScreen = GameScreen.firstVideo;
        break;

      case GameScreen.statistics:
        previousScreen = GameScreen.strategy;
        break;

      default:
        return;
    }

    emit(state.copyWith(currentScreen: previousScreen));
  }

  Future<void> _onInitializeGame(
      InitializeGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(
      status: GameStatus.initial,
      currentScreen: GameScreen.introduction,
      videos: [],
      currentPin: null,
      userStatistics: null,
      userGuessIsDeepfake: null,
      isCorrectGuess: null,
      errorMessage: null,
      generatedPin: null,
      currentStrategyIndex: 0,
      viewedStrategyIds: {},
    ));
  }

  Future<void> _onUpdateSelectedVideo(
      UpdateSelectedVideo event, Emitter<GameState> emit) async {
    // Only update the selection without recording the attempt
    emit(state.copyWith(
      userGuessIsDeepfake: event.isDeepfake,
    ));
  }

  Future<void> _onStrategyIndexChanged(
      StrategyIndexChanged event, Emitter<GameState> emit) async {
    final newIndex = event.newIndex;
    final String? previousStrategyId = event.previousStrategyId;

    final updatedViewedIds = Set<String>.from(state.viewedStrategyIds);

    // Nur wenn eine vorherige Strategie existiert und sich geändert hat,
    // markieren wir sie als angesehen
    if (previousStrategyId != null) {
      updatedViewedIds.add(previousStrategyId);
    }

    emit(state.copyWith(
      currentStrategyIndex: newIndex,
      viewedStrategyIds: updatedViewedIds,
    ));
  }

  String _generatePlayerId() {
    if (state.currentPin != null) {
      return state.currentPin.toString();
    }
    return 'temp_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<GameState> emit) async {
    emit(state.copyWith(locale: event.locale));

    if (state.userStatistics != null) {
      try {
        final updatedStats =
            state.userStatistics!.copyWith(locale: event.locale);

        final result = await _statisticsRepository.updateUserSettings(
          pin: state.currentPin,
          updatedStats: updatedStats,
        );

        emit(state.copyWith(userStatistics: result));
      } catch (e) {
        // Bei Fehler nur eine Meldung ausgeben, UI bleibt bei neuer Sprache
        print('Failed to save language setting: $e');
      }
    } else {
      final emptyStats =
          UserStatistics.temporary().copyWith(locale: event.locale);
      emit(state.copyWith(userStatistics: emptyStats));
    }
  }

  Future<void> _onOverlayCompleted(
      OverlayCompleted event, Emitter<GameState> emit) async {
    final updatedOverlays = Set<OverlayType>.from(state.shownOverlays)
      ..add(event.overlayType);

    emit(state.copyWith(shownOverlays: updatedOverlays));
  }

  Future<void> _onSetInitialConfidenceRating(
      SetInitialConfidenceRating event, Emitter<GameState> emit) async {
    try {
      // Speichere den Wert in internal_statistics_repository wenn nötig
      if (state.playerId != null) {
        await _internalStatsRepository.recordConfidenceRating(
          playerId: state.playerId!,
          rating: event.rating,
        );
      }

      // Aktualisiere den State
      emit(state.copyWith(
        initialConfidenceRating: event.rating,
      ));
    } catch (e) {
      print('Failed to save confidence rating: $e');
      // Wir wollen den Spielfluss nicht unterbrechen, wenn es Fehler gibt,
      // also senden wir keine Fehlermeldung an den Benutzer
    }
  }

  Future<void> _onSurveyCompleted(
      SurveyCompleted event, Emitter<GameState> emit) async {
    // Starte das Spiel nach der Umfrage
    emit(state.copyWith(
      status: GameStatus.playing,
      currentScreen: GameScreen.firstVideo,
    ));
  }
}
