import 'package:deepfake_detector/constants/tutorial_types.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import '../../config/localization/app_locale.dart';

enum GameScreen {
  introduction,
  login,
  firstVideo,
  decision,
  result,
  strategy,
  statistics
}

/// Extension für GameScreen-spezifische Navigation
extension GameScreenNavigation on GameScreen {
  bool get canNavigateBack {
    switch (this) {
      case GameScreen.introduction:
      case GameScreen.result:
      case GameScreen.strategy:
        return false;
      default:
        return true;
    }
  }

  bool get canNavigateForward {
    switch (this) {
      case GameScreen.strategy:
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
  loginError,
  playing,
}

class GameState {
  final GameStatus status;
  final GameScreen currentScreen;
  final List<Video> videos;
  final int? currentPin;
  final UserStatistics? userStatistics;
  final bool? userGuessIsDeepfake;
  final bool? isCorrectGuess;
  final String? errorMessage;
  final int? generatedPin;
  final int currentStrategyIndex;
  final String? playerId;
  final AppLocale locale;
  final Set<String> viewedStrategyIds;
  final int totalUniquePairs;
  final Set<TutorialTypes> shownTutorials;

  bool get isTemporarySession => currentPin == null;
  bool get hasStatistics => userStatistics != null;
  bool get canGeneratePin => isTemporarySession && hasStatistics;
  bool get showStatisticsSavePrompt =>
      canGeneratePin &&
      currentScreen == GameScreen.strategy &&
      userStatistics!.totalAttempts > 0;

  const GameState({
    required this.status,
    required this.currentScreen,
    required this.videos,
    this.currentPin,
    this.userStatistics,
    this.userGuessIsDeepfake,
    this.isCorrectGuess,
    this.errorMessage,
    this.generatedPin,
    required this.currentStrategyIndex,
    this.playerId,
    required this.locale,
    required this.viewedStrategyIds,
    required this.totalUniquePairs,
    this.shownTutorials = const {},
  });

  const GameState.initial()
      : status = GameStatus.initial,
        currentScreen = GameScreen.introduction,
        videos = const [],
        currentPin = null,
        userStatistics = null,
        userGuessIsDeepfake = null,
        isCorrectGuess = null,
        errorMessage = null,
        generatedPin = null,
        currentStrategyIndex = 0,
        playerId = null,
        locale = AppLocale.de,
        viewedStrategyIds = const {},
        shownTutorials = const <TutorialTypes>{},
        totalUniquePairs = 0;

  GameState copyWith({
    GameStatus? status,
    GameScreen? currentScreen,
    List<Video>? videos,
    Object? currentPin = _sentinel,
    Object? userStatistics = _sentinel,
    Object? userGuessIsDeepfake = _sentinel,
    Object? isCorrectGuess = _sentinel,
    Object? errorMessage = _sentinel,
    Object? generatedPin = _sentinel,
    int? currentStrategyIndex,
    Object? playerId = _sentinel,
    AppLocale? locale,
    Set<String>? viewedStrategyIds,
    int? totalUniquePairs,
    Set<TutorialTypes>? shownTutorials,
  }) {
    return GameState(
      status: status ?? this.status,
      currentScreen: currentScreen ?? this.currentScreen,
      videos: videos ?? this.videos,
      currentPin:
          currentPin == _sentinel ? this.currentPin : currentPin as int?,
      userStatistics: userStatistics == _sentinel
          ? this.userStatistics
          : userStatistics as UserStatistics?,
      userGuessIsDeepfake: userGuessIsDeepfake == _sentinel
          ? this.userGuessIsDeepfake
          : userGuessIsDeepfake as bool?,
      isCorrectGuess: isCorrectGuess == _sentinel
          ? this.isCorrectGuess
          : isCorrectGuess as bool?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      generatedPin:
          generatedPin == _sentinel ? this.generatedPin : generatedPin as int?,
      currentStrategyIndex: currentStrategyIndex ?? this.currentStrategyIndex,
      playerId: playerId == _sentinel ? this.playerId : playerId as String?,
      locale: locale ?? this.locale,
      viewedStrategyIds: viewedStrategyIds ?? this.viewedStrategyIds,
      totalUniquePairs: totalUniquePairs ?? this.totalUniquePairs,
      shownTutorials: shownTutorials ?? this.shownTutorials,
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
          userGuessIsDeepfake == other.userGuessIsDeepfake &&
          isCorrectGuess == other.isCorrectGuess &&
          generatedPin == other.generatedPin &&
          currentStrategyIndex == other.currentStrategyIndex &&
          playerId == other.playerId &&
          locale == other.locale &&
          totalUniquePairs == other.totalUniquePairs &&
          shownTutorials == other.shownTutorials &&
          viewedStrategyIds.length == other.viewedStrategyIds.length;

  @override
  int get hashCode =>
      status.hashCode ^
      currentScreen.hashCode ^
      currentPin.hashCode ^
      userGuessIsDeepfake.hashCode ^
      isCorrectGuess.hashCode ^
      generatedPin.hashCode ^
      currentStrategyIndex.hashCode ^
      playerId.hashCode ^
      locale.hashCode ^
      totalUniquePairs.hashCode ^
      shownTutorials.hashCode ^
      viewedStrategyIds.hashCode;

  @override
  String toString() =>
      'GameState(status: $status, screen: $currentScreen, pin: $currentPin, playerId: $playerId, currentStrategyIndex: $currentStrategyIndex, viewedStrategiesCount: ${viewedStrategyIds.length})';

  bool hasTutorialBeenShown(TutorialTypes type) {
    return shownTutorials.contains(type);
  }
}

const _sentinel = Object();
