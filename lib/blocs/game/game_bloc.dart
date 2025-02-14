import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/video_repository.dart';
import '../../repositories/statistics_repository.dart';
import '../../repositories/user_repository.dart';
import '../../models/statistics_model.dart';
import '../../exceptions/app_exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final VideoRepository _videoRepository;
  final StatisticsRepository _statisticsRepository;
  final UserRepository _userRepository;

  GameBloc({
    required VideoRepository videoRepository,
    required StatisticsRepository statisticsRepository,
    required UserRepository userRepository,
  })  : _videoRepository = videoRepository,
        _statisticsRepository = statisticsRepository,
        _userRepository = userRepository,
        super(const GameState.initial()) {
    on<QuickStartGame>(_onQuickStartGame);
    on<LoginWithPin>(_onLoginWithPin);
    on<ShowLogin>(_onShowLogin);
    on<CancelLogin>(_onCancelLogin);
    on<NextScreen>(_onNextScreen);
    on<PreviousScreen>(_onPreviousScreen);
    on<SelectDeepfake>(_onSelectDeepfake);
    on<RestartGame>(_onRestartGame);
    on<GeneratePin>(_onGeneratePin);
    on<CheckPin>(_onCheckPin);
    on<InitializeGame>(_onInitializeGame);
    on<UpdateSelectedVideo>(_onUpdateSelectedVideo);
    on<StrategyIndexChanged>(_onStrategyIndexChanged);
  }

  Future<void> _onQuickStartGame(
      QuickStartGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final videos = await _videoRepository.getRandomVideoPair({});

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        currentPin: null,
        videos: videos,
        // Initialisiere temporäre Statistiken
        userStatistics: UserStatistics.temporary(),
        errorMessage: null,
      ));
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

      // Get existing statistics and create new instance with empty recentAttempts
      final existingStats =
          await _statisticsRepository.getStatistics(event.pin);
      final videos =
          await _videoRepository.getRandomVideoPair(existingStats.seenVideoIds);

      final statistics = existingStats.copyWith(recentAttempts: []);
      await _statisticsRepository.resetRecentAttempts(event.pin);

      emit(state.copyWith(
          status: GameStatus.playing,
          currentScreen: GameScreen.firstVideo,
          currentPin: event.pin,
          userStatistics: statistics,
          videos: videos,
          errorMessage: null));
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

      // Konvertiere temporäre Statistiken wenn vorhanden
      if (state.userStatistics != null && state.userStatistics!.isTemporary) {
        final permanentStats =
            await _statisticsRepository.convertTemporaryStats(
          state.userStatistics!,
          pin,
        );

        emit(state.copyWith(
          currentPin: pin,
          generatedPin: pin,
          userStatistics: permanentStats,
          status: GameStatus.playing,
        ));
      } else {
        // Erstelle neue permanente Statistiken
        final newStats = UserStatistics.withPin(pin);
        emit(state.copyWith(
          currentPin: pin,
          generatedPin: pin,
          userStatistics: newStats,
          status: GameStatus.playing,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to generate PIN: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSelectDeepfake(
      SelectDeepfake event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing ||
        state.currentScreen != GameScreen.comparison ||
        event.videoIndex >= state.videos.length) {
      return;
    }

    final selectedVideo = state.videos[event.videoIndex];
    final isCorrect = selectedVideo.isDeepfake;

    try {
      final attempt = GameAttempt(
        timestamp: DateTime.now(),
        wasCorrect: isCorrect,
        videoIds: state.videos.map((video) => video.id).toList(),
        selectedVideoId: selectedVideo.id,
      );

      // Aktualisiere Statistiken basierend auf PIN-Status
      final updatedStats = await _statisticsRepository.addAttempt(
        attempt,
        pin: state.currentPin,
        stats: state.userStatistics,
      );

      emit(state.copyWith(
        selectedVideoIndex: event.videoIndex,
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
          await _videoRepository.getRandomVideoPair(statistics.seenVideoIds);

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        videos: videos,
        userStatistics: statistics,
        selectedVideoIndex: null,
        isCorrectGuess: null,
        errorMessage: null,
        generatedPin: null,
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
        emit(state.copyWith(currentScreen: GameScreen.secondVideo));
        break;

      case GameScreen.secondVideo:
        if (state.videos.length == 2) {
          emit(state.copyWith(currentScreen: GameScreen.comparison));
        }

      case GameScreen.comparison:
        if (state.selectedVideoIndex != null) {
          emit(state.copyWith(currentScreen: GameScreen.result));
        }
        break;

      case GameScreen.result:
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
      case GameScreen.firstVideo:
        previousScreen = GameScreen.introduction;
        break;

      case GameScreen.secondVideo:
        previousScreen = GameScreen.firstVideo;
        break;

      case GameScreen.comparison:
        previousScreen = GameScreen.secondVideo;
        break;

      case GameScreen.result:
        previousScreen = GameScreen.comparison;
        emit(state.copyWith(
          currentScreen: previousScreen,
          selectedVideoIndex: null,
          isCorrectGuess: null,
        ));
        return;

      case GameScreen.statistics:
        previousScreen = GameScreen.result;
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
      selectedVideoIndex: null,
      isCorrectGuess: null,
      errorMessage: null,
      generatedPin: null,
      currentStrategyIndex: 0,
    ));
  }

  Future<void> _onUpdateSelectedVideo(
      UpdateSelectedVideo event, Emitter<GameState> emit) async {
    // Only update the selection without recording the attempt
    emit(state.copyWith(
      selectedVideoIndex: event.videoIndex,
    ));
  }

  Future<void> _onStrategyIndexChanged(
      StrategyIndexChanged event, Emitter<GameState> emit) async {
    emit(state.copyWith(
      currentStrategyIndex: event.newIndex,
    ));
  }
}
