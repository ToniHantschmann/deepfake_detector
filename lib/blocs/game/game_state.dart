import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';

enum GameScreen {
  introduction,
  login,
  firstVideo,
  secondVideo,
  comparison,
  result,
  statistics,
}

enum GameStatus {
  initial,
  loading,
  error,
  showLogin,
  playing,
}

class GameState {
  final GameStatus status;
  final GameScreen currentScreen;
  final List<Video> videos;
  final List<String> availableUsers;
  final String? currentUser;
  final UserStatistics? userStatistics;
  final int? selectedVideoIndex;
  final bool? isCorrectGuess;
  final String? errorMessage;
  final bool isTemporaryUser;
  final bool showLoginOverlay;

  static const _sentinel = Object();

  const GameState({
    required this.status,
    required this.currentScreen,
    required this.videos,
    required this.availableUsers,
    this.currentUser,
    this.userStatistics,
    this.selectedVideoIndex,
    this.isCorrectGuess,
    this.errorMessage,
    this.isTemporaryUser = false,
    this.showLoginOverlay = false,
  });

  const GameState.initial()
      : status = GameStatus.initial,
        currentScreen = GameScreen.introduction,
        videos = const [],
        availableUsers = const [],
        currentUser = null,
        userStatistics = null,
        selectedVideoIndex = null,
        isCorrectGuess = null,
        errorMessage = null,
        isTemporaryUser = false,
        showLoginOverlay = false;

  GameState copyWith({
    GameStatus? status,
    GameScreen? currentScreen,
    List<Video>? videos,
    List<String>? availableUsers,
    Object? currentUser = _sentinel,
    Object? userStatistics = _sentinel,
    Object? selectedVideoIndex = _sentinel,
    Object? isCorrectGuess = _sentinel,
    Object? errorMessage = _sentinel,
    bool? isTemporaryUser,
    bool? showLoginOverlay,
  }) {
    return GameState(
      status: status ?? this.status,
      currentScreen: currentScreen ?? this.currentScreen,
      videos: videos ?? this.videos,
      availableUsers: availableUsers ?? this.availableUsers,
      currentUser:
          currentUser == _sentinel ? this.currentUser : currentUser as String?,
      userStatistics: userStatistics == _sentinel
          ? this.userStatistics
          : userStatistics as UserStatistics?,
      selectedVideoIndex: selectedVideoIndex == _sentinel
          ? this.selectedVideoIndex
          : selectedVideoIndex as int?,
      isCorrectGuess: isCorrectGuess == _sentinel
          ? this.isCorrectGuess
          : isCorrectGuess as bool?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      isTemporaryUser: isTemporaryUser ?? this.isTemporaryUser,
      showLoginOverlay: showLoginOverlay ?? this.showLoginOverlay,
    );
  }
}
