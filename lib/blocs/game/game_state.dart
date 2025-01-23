import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';

enum GameScreen {
  introduction,
  login,
  firstVideo,
  secondVideo,
  comparison,
  result,
  statistics
}

/// Extension für GameScreen-spezifische Navigation
extension GameScreenNavigation on GameScreen {
  bool get canNavigateBack {
    switch (this) {
      case GameScreen.introduction:
      case GameScreen.result:
        return false;
      default:
        return true;
    }
  }

  bool get canNavigateForward {
    switch (this) {
      case GameScreen.statistics:
        return false;
      default:
        return true;
    }
  }
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
  final String? currentPin; // Null bedeutet temporäre Session
  final UserStatistics? userStatistics;
  final int? selectedVideoIndex;
  final bool? isCorrectGuess;
  final String? errorMessage;
  final bool isPinChecking;
  final String? generatedPin;

  bool get isTemporarySession => currentPin == null;
  bool get hasStatistics => userStatistics != null;
  bool get canGeneratePin => isTemporarySession && hasStatistics;
  bool get showStatisticsSavePrompt =>
      canGeneratePin &&
      currentScreen == GameScreen.statistics &&
      userStatistics!.totalAttempts > 0;

  const GameState({
    required this.status,
    required this.currentScreen,
    required this.videos,
    this.currentPin,
    this.userStatistics,
    this.selectedVideoIndex,
    this.isCorrectGuess,
    this.errorMessage,
    this.isPinChecking = false,
    this.generatedPin,
  });

  const GameState.initial()
      : status = GameStatus.initial,
        currentScreen = GameScreen.introduction,
        videos = const [],
        currentPin = null,
        userStatistics = null,
        selectedVideoIndex = null,
        isCorrectGuess = null,
        errorMessage = null,
        isPinChecking = false,
        generatedPin = null;

  GameState copyWith({
    GameStatus? status,
    GameScreen? currentScreen,
    List<Video>? videos,
    Object? currentPin = _sentinel,
    Object? userStatistics = _sentinel,
    Object? selectedVideoIndex = _sentinel,
    Object? isCorrectGuess = _sentinel,
    Object? errorMessage = _sentinel,
    bool? showLoginOverlay,
    bool? isPinChecking,
    Object? generatedPin = _sentinel,
  }) {
    return GameState(
      status: status ?? this.status,
      currentScreen: currentScreen ?? this.currentScreen,
      videos: videos ?? this.videos,
      currentPin:
          currentPin == _sentinel ? this.currentPin : currentPin as String?,
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
      isPinChecking: isPinChecking ?? this.isPinChecking,
      generatedPin: generatedPin == _sentinel
          ? this.generatedPin
          : generatedPin as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          currentScreen == other.currentScreen &&
          currentPin == other.currentPin &&
          selectedVideoIndex == other.selectedVideoIndex &&
          isCorrectGuess == other.isCorrectGuess &&
          isPinChecking == other.isPinChecking &&
          generatedPin == other.generatedPin;

  @override
  int get hashCode =>
      status.hashCode ^
      currentScreen.hashCode ^
      currentPin.hashCode ^
      selectedVideoIndex.hashCode ^
      isCorrectGuess.hashCode ^
      isPinChecking.hashCode ^
      generatedPin.hashCode;

  @override
  String toString() =>
      'GameState(status: $status, screen: $currentScreen, pin: $currentPin)';
}

const _sentinel = Object();
