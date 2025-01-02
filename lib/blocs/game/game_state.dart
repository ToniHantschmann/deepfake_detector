import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';

enum GameScreen {
  introduction,
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
  login,
  ready,
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
        errorMessage = null;

  GameState copyWith({
    GameStatus? status,
    GameScreen? currentScreen,
    List<Video>? videos,
    List<String>? availableUsers,
    String? currentUser,
    UserStatistics? userStatistics,
    int? selectedVideoIndex,
    bool? isCorrectGuess,
    String? errorMessage,
  }) {
    return GameState(
      status: status ?? this.status,
      currentScreen: currentScreen ?? this.currentScreen,
      videos: videos ?? this.videos,
      availableUsers: availableUsers ?? this.availableUsers,
      currentUser: currentUser ?? this.currentUser,
      userStatistics: userStatistics ?? this.userStatistics,
      selectedVideoIndex: selectedVideoIndex ?? this.selectedVideoIndex,
      isCorrectGuess: isCorrectGuess ?? this.isCorrectGuess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
