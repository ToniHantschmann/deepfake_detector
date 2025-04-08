// lib/config/localization/string_types.dart

abstract class AppStrings {
  const AppStrings();

  IntroductionScreenStrings get introduction;
  VideoScreenStrings get video;
  DecisionScreenStrings get comparison;
  ResultScreenStrings get result;
  StrategyScreenStrings get strategies;
  StatisticsScreenStrings get statistics;
  AuthStrings get auth;
  CommonStrings get common;
  ErrorStrings get errors;
  StrategyCardStrings get strategyCard;
  ProgressBarStrings get progressBar;
  PinDisplayStrings get pinDisplay;
  TutorialStrings get tutorial;
  DeepfakeReasonStrings get deepfakeReasons;
  VideoPlayerStrings get videoPlayer;
  SurveyStrings get survey;
  InactivityStrings get inactivity;
}

abstract class IntroductionScreenStrings {
  const IntroductionScreenStrings();

  String get title;
  String get subtitle;
  String get description;
  String get startButton;
  String get loginButton;
  String get challenge;
}

abstract class VideoScreenStrings {
  const VideoScreenStrings();

  String get playButton;
  String get pauseButton;
  String get replayButton;
  String get nextButton;
  String get backButton;
  String get loading;
  String get buffering;
}

abstract class DecisionScreenStrings {
  const DecisionScreenStrings();

  String get title;
  String get subtitle;
  String get selectionButton;
  String get confirmButton;

  String get realButtonLabel;
  String get deepfakeButtonLabel;
  String get questionLabel;
  String get instructionLabel;
}

abstract class ResultScreenStrings {
  const ResultScreenStrings();

  String get correctTitle;
  String get wrongTitle;
  String get tapToContinue;
  String get explanationTitle;
  String get reasonPrefix;
  String get correctFormat;
  String get nextButton;

  String get videoComparisonTitle;
  String get shownVideoTitle;
  String get comparisonVideoTitle;
  String get deepfakeIndicator;
  String get realVideoIndicator;
  String get watchVideoButton;
  String get yourDecision;
}

abstract class StrategyScreenStrings {
  const StrategyScreenStrings();

  String get title;
  String get subtitle;
  String get nextGameButton;
  String get getPinButton;
  String get statsButton;
}

abstract class StatisticsScreenStrings {
  const StatisticsScreenStrings();

  String get title;
  String get subtitle;
  String get correctAnswers;
  String get viewedPairsTitle;
  String get progressLabel;
  String get nextGameButton;
  String get saveGameButton;
  String get statisticsOf;
  String get currentRun;
  String get overallStats;
}

abstract class AuthStrings {
  const AuthStrings();

  // Login Overlay
  String get loginTitle;
  String get loginSubtitle;
  String get continueWithoutPin;
  String get invalidPinError;
  String get loginButtonText;
  String get closeLoginButton;

  // PIN Display
  String get enterPinPrompt;
  String get pinPlaceholder;
  String get pinInputError;

  // PIN Overlay
  String get pinTitle;
  String get pinSubtitle;
  String get pinGeneratedTitle;
  String get pinSavePrompt;
  String get copyPin;
  String get pinCopied;
  String get startNextGame;
  String get closeOverlay;
  String get autoCloseText;

  // Number Pad
  String get backspace;
  String get clear;
}

abstract class CommonStrings {
  const CommonStrings();

  String get retry;
  String get cancel;
  String get confirm;
  String get back;
  String get next;
  String get loading;
}

abstract class ErrorStrings {
  const ErrorStrings();

  String get generalError;
  String get videoLoadError;
  String get invalidPin;
  String get networkError;
  String get unknownError;
  String get retryMessage;
}

abstract class ProgressBarStrings {
  const ProgressBarStrings();

  String get firstVideo;
  String get secondVideo;
  String get decision;
  String get result;
  String get strategies;
  String get statistics;
}

abstract class PinDisplayStrings {
  const PinDisplayStrings();

  String get pinGeneratedTitle;
  String get pinSavePrompt;
  String get pinDisplayTitle;
  String get pinDisplayInstructions;
  String get copyPin;
  String get pinCopied;
  String get startNextGame;
  String get closeOverlay;
}

abstract class TutorialStrings {
  const TutorialStrings();

  String get swipeTooltip;
  String get videoTapTooltip;
  String get touchToContinue;
  String get screenSwipeInstruction;
  String get pinGenerateTutorial;
}

abstract class VideoPlayerStrings {
  const VideoPlayerStrings();

  String get deepfakeLabel;
  String get realLabel;
}

abstract class SurveyStrings {
  const SurveyStrings();

  String get confidenceTitle;
  String get confidenceQuestion;
  String get confidenceLow;
  String get confidenceHigh;
  String get continueButton;
}

abstract class StrategyCardStrings {
  const StrategyCardStrings();

  // Face Manipulation
  String get faceManipulationTitle;
  String get faceManipulationDescription;
  String get faceManipulationOriginal;
  String get faceManipulationModified;
  String get faceManipulationIndicatorNormal;
  String get faceManipulationIndicatorManipulated;

  // Facial Features
  String get facialFeaturesTitle;
  String get facialFeaturesDescription;
  String get facialFeaturesOriginal;
  String get facialFeaturesModified;
  String get facialFeaturesIndicatorNormal;
  String get facialFeaturesIndicatorManipulated;

  // Blinking
  String get blinkingTitle;
  String get blinkingDescription;
  String get blinkingNatural;
  String get blinkingUnnatural;
  String get blinkingIndicatorNormal;
  String get blinkingIndicatorFast;

  // Eye and Eyebrows
  String get eyeTitle;
  String get eyeDescription;
  String get eyeNatural;
  String get eyeArtificial;
  String get eyeIndicatorNormal;
  String get eyeIndicatorArtificial;

  // Glasses Strategy
  String get glassesTitle;
  String get glassesDescription;
  String get glassesNatural;
  String get glassesArtificial;
  String get glassesIndicatorNormal;
  String get glassesIndicatorArtificial;

  // Facial Hair
  String get facialHairTitle;
  String get facialHairDescription;
  String get facialHairNatural;
  String get facialHairArtificial;
  String get facialHairIndicatorNormal;
  String get facialHairIndicatorArtificial;

  // Moles/Birthmarks
  String get molesTitle;
  String get molesDescription;
  String get molesNatural;
  String get molesArtificial;
  String get molesIndicatorNormal;
  String get molesIndicatorArtificial;

  // Lip Sync
  String get lipSyncTitle;
  String get lipSyncDescription;
  String get lipSyncNatural;
  String get lipSyncArtificial;
  String get lipSyncIndicatorNormal;
  String get lipSyncIndicatorArtificial;

  // Internet research
  String get researchTitle;
  String get researchDescription;
  String get researchStepSearch;
  String get researchStepVerify;
  String get researchStepAnalyze;
  String get researchButtonText;
  String get researchTip;
  String get researchStatusNone;
  String get researchStatusInProgress;
  String get researchStatusComplete;

  // General Strategy UI
  String get toggleOriginal;
  String get toggleManipulated;
  String get indicatorNormal;
  String get indicatorArtificial;
}

abstract class DeepfakeReasonStrings {
  const DeepfakeReasonStrings();

  // Gründe für verschiedene Video-IDs
  List<String> getReasonsForVideo(String pairId);

  // Generische Gründe als Fallback
  List<String> get genericReasons;
}

abstract class InactivityStrings {
  const InactivityStrings();

  // Countdown-Overlay
  String get inactivityTitle;
  String get inactivityMessage;
  String get continueButton;
}
