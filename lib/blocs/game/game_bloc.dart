import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../models/video_model.dart';
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
    on<InitializeGame>(_onInitializeGame);
    on<LoginUser>(_onLoginUser);
    on<StartGame>(_onStartGame);
    on<NextScreen>(_onNextScreen);
    on<SelectDeepfake>(_onSelectDeepfake);
    on<RestartGame>(_onRestartGame);
  }

  Future<void> _onInitializeGame(
      InitializeGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      final users = await _userRepository.getUsers();
      emit(state.copyWith(
        status: GameStatus.login,
        availableUsers: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e is UserException ? e.message : 'Failed to load users',
      ));
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<GameState> emit) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      // If user doesn't exist, create new user
      if (!state.availableUsers.contains(event.username)) {
        await _userRepository.addUser(event.username);
      }

      // Load user statistics
      final statistics =
          await _statisticsRepository.getStatistics(event.username);

      emit(state.copyWith(
        status: GameStatus.ready,
        currentUser: event.username,
        userStatistics: statistics,
      ));

      // Automatically start the game after successful login
      add(const StartGame());
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e is UserException ? e.message : 'Failed to login user',
      ));
    }
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    if (state.currentUser == null) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: 'No user logged in',
      ));
      return;
    }

    emit(state.copyWith(status: GameStatus.loading));

    try {
      final videos = await _videoRepository.getRandomVideoPair();

      emit(state.copyWith(
        status: GameStatus.playing,
        videos: videos,
        currentScreen: GameScreen.introduction,
        selectedVideoIndex: null, // Reset selection
        isCorrectGuess: null, // Reset result
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: e is VideoException ? e.message : 'Failed to load videos',
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
            final updatedStats =
                await _statisticsRepository.getStatistics(state.currentUser!);
            emit(state.copyWith(
              currentScreen: GameScreen.statistics,
              userStatistics: updatedStats,
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
        break;
    }
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

      emit(state.copyWith(
        selectedVideoIndex: event.videoIndex,
        isCorrectGuess: isCorrect,
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
    final currentStats = state.userStatistics;

    if (currentUser != null && currentStats != null) {
      // Verify user still exists
      try {
        final exists = await _userRepository.userExists(currentUser);
        if (!exists) {
          emit(const GameState.initial());
          add(const InitializeGame());
          return;
        }

        emit(state.copyWith(
          status: GameStatus.ready,
          currentUser: currentUser,
          userStatistics: currentStats,
          videos: const [],
          selectedVideoIndex: null,
          isCorrectGuess: null,
          errorMessage: null,
        ));

        add(const StartGame());
      } catch (e) {
        emit(state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Failed to verify user: ${e.toString()}',
        ));
      }
    } else {
      emit(const GameState.initial());
      add(const InitializeGame());
    }
  }
}
