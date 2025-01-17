import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../models/video_model.dart';
import '../../repositories/video_repository.dart';
import '../../repositories/statistics_repository.dart';
import '../../repositories/user_repository.dart';
import '../../models/statistics_model.dart';
import '../../exceptions/app_exceptions.dart';
import '../../utils/temp_user_service.dart';
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
    on<LoginExistingUser>(_onLoginExistingUser);
    on<RegisterNewUser>(_onRegisterNewUser);
    on<ShowLogin>(_onShowLogin);
    on<CancelLogin>(_onCancelLogin);
    on<NextScreen>(_onNextScreen);
    on<PreviousScreen>(_onPreviousScreen);
    on<SelectDeepfake>(_onSelectDeepfake);
    on<RestartGame>(_onRestartGame);
    on<SaveTempUser>(_onSaveTempUser);
    on<CheckPin>(_onCheckPin);
    on<SetPinCheckResult>(_onSetPinCheckResult);
    on<ShowRegister>(_onShowRegister);
    on<CancelRegister>(_onCancelRegister);
  }

  /// Handler zum Anzeigen des Login-Dialogs
  void _onShowLogin(ShowLogin event, Emitter<GameState> emit) {
    emit(state.copyWith(
      status: GameStatus.showLogin,
      showLoginOverlay: true,
    ));
  }

  void _onShowRegister(ShowRegister event, Emitter<GameState> emit) {
    emit(state.copyWith(
      status: GameStatus.showRegister,
      showRegisterOverlay: true,
    ));
  }

  void _onCancelLogin(CancelLogin event, Emitter<GameState> emit) {
    emit(state.copyWith(
      status: GameStatus.initial,
      showLoginOverlay: false,
      pinMatchingUsernames: [],
      isPinChecking: false,
    ));
  }

  void _onCancelRegister(CancelRegister event, Emitter<GameState> emit) {
    emit(state.copyWith(
      status: GameStatus.playing,
      showRegisterOverlay: false,
    ));
    emit(state.copyWith(
      pinMatchingUsernames: [],
      isPinChecking: false,
    ));
  }

  Future<void> _onCheckPin(CheckPin event, Emitter<GameState> emit) async {
    emit(state.copyWith(isPinChecking: true));

    try {
      final users = await _userRepository.getUsersByPin(event.pin);
      final usernames = users.map((u) => u.username).toList();

      emit(state.copyWith(
        isPinChecking: false,
        pinMatchingUsernames: usernames,
      ));
    } catch (e) {
      emit(state.copyWith(
        isPinChecking: false,
        status: GameStatus.error,
        errorMessage: 'Failed to check PIN: ${e.toString()}',
      ));
    }
  }

  void _onSetPinCheckResult(SetPinCheckResult event, Emitter<GameState> emit) {
    emit(state.copyWith(pinMatchingUsernames: event.matchingUsernames));
  }

  Future<void> _onQuickStartGame(
      QuickStartGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final tempUsername = TempUserService.generateTempUsername();

      // Temporären User anlegen
      await _userRepository.addUser(tempUsername);

      // Statistiken initialisieren
      final statistics =
          await _statisticsRepository.getStatistics(tempUsername);

      final videos = await _videoRepository.getRandomVideoPair();

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        currentUser: tempUsername,
        userStatistics: statistics,
        isTemporaryUser: true,
        videos: videos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to create temporary user: $e',
      ));
    }
  }

  Future<void> _onLoginExistingUser(
      LoginExistingUser event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      // Prüfe ob User existiert
      final exists = await _userRepository.userExists(event.username);
      if (!exists) {
        throw UserException('User does not exist');
      }

      // Lade Statistiken
      final statistics =
          await _statisticsRepository.getStatistics(event.username);

      // Hole Videos für das Spiel
      final videos = await _videoRepository.getRandomVideoPair();

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        currentUser: event.username,
        userStatistics: statistics,
        isTemporaryUser: false,
        videos: videos,
        showLoginOverlay: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRegisterNewUser(
      RegisterNewUser event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      // Erstelle neuen User
      await _userRepository.addUser(event.username);

      // Initialisiere Statistiken
      final statistics =
          await _statisticsRepository.getStatistics(event.username);

      // Hole Videos für das Spiel
      final videos = await _videoRepository.getRandomVideoPair();

      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        currentUser: event.username,
        userStatistics: statistics,
        isTemporaryUser: false,
        videos: videos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Registration failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSaveTempUser(
      SaveTempUser event, Emitter<GameState> emit) async {
    if (!state.isTemporaryUser || state.currentUser == null) {
      return;
    }

    emit(state.copyWith(status: GameStatus.loading));

    try {
      final oldUsername = state.currentUser!;

      // Erstelle neuen permanenten User
      await _userRepository.addUser(event.username);

      // Kopiere Statistiken vom temporären zum permanenten User
      final oldStats = await _statisticsRepository.getStatistics(oldUsername);
      await _statisticsRepository.copyStatistics(oldUsername, event.username);

      // Lösche temporären User
      await _userRepository.removeUser(oldUsername);

      emit(state.copyWith(
        currentUser: event.username,
        userStatistics: oldStats,
        isTemporaryUser: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to convert temporary user: ${e.toString()}',
      ));
    }
  }

  Future<void> _onNextScreen(NextScreen event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing || state.videos.isEmpty) return;

    switch (state.currentScreen) {
      case GameScreen.introduction:
        emit(state.copyWith(currentScreen: GameScreen.firstVideo));
        break;
      case GameScreen.login:
        emit(state.copyWith(currentScreen: GameScreen.login));
        break;

      case GameScreen.firstVideo:
        emit(state.copyWith(currentScreen: GameScreen.secondVideo));
        break;

      case GameScreen.secondVideo:
        emit(state.copyWith(currentScreen: GameScreen.comparison));
        break;

      case GameScreen.comparison:
        if (state.selectedVideoIndex != null) {
          emit(state.copyWith(currentScreen: GameScreen.result));
        }
        break;
      case GameScreen.result:
        if (state.currentUser != null) {
          try {
            emit(state.copyWith(
              currentScreen: GameScreen.statistics,
            ));
          } catch (e) {
            emit(state.copyWith(
              status: GameStatus.error,
              errorMessage: 'Failed to load statistics',
            ));
          }
        }
        break;

      case GameScreen.statistics:
        add(const RestartGame());
        break;

      case GameScreen.register:
        emit(state.copyWith(currentScreen: GameScreen.register));
        break;
    }
  }

  /// Handler für die Zurück-Navigation
  Future<void> _onPreviousScreen(
    PreviousScreen event,
    Emitter<GameState> emit,
  ) async {
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
        // Reset selection when going back from result
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
        // For introduction and login screens, do nothing
        return;
    }

    emit(state.copyWith(currentScreen: previousScreen));
  }

  Future<void> _onSelectDeepfake(
      SelectDeepfake event, Emitter<GameState> emit) async {
    if (state.status != GameStatus.playing ||
        state.currentScreen != GameScreen.comparison ||
        state.currentUser == null ||
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

      await _statisticsRepository.addAttempt(state.currentUser!, attempt);
      final updatedStats =
          await _statisticsRepository.getStatistics(state.currentUser!);

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
    final currentUser = state.currentUser;
    final isTemp = state.isTemporaryUser;

    if (currentUser == null) {
      // Kein User vorhanden - zurück zum Start
      emit(const GameState.initial());
      return;
    }

    emit(state.copyWith(status: GameStatus.loading));

    try {
      // Prüfe ob User noch existiert
      final exists = await _userRepository.userExists(currentUser);
      if (!exists) {
        emit(const GameState.initial());
        return;
      }

      // Hole aktuelle Statistiken
      final statistics = await _statisticsRepository.getStatistics(currentUser);

      // Hole neue Videos für die nächste Runde
      final videos = await _videoRepository.getRandomVideoPair();

      // Setze Spiel zurück und behalte User-Informationen
      emit(state.copyWith(
        status: GameStatus.playing,
        currentScreen: GameScreen.firstVideo,
        videos: videos,
        userStatistics: statistics,
        selectedVideoIndex: null,
        isCorrectGuess: null,
        errorMessage: null,
        isTemporaryUser: isTemp,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'Failed to restart game: ${e.toString()}',
      ));
    }
  }
}
