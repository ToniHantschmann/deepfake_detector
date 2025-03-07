// lib/config/localization/string_types.dart

abstract class AppStrings {
  const AppStrings();

  IntroductionScreenStrings get introduction;
  VideoScreenStrings get video;
  ComparisonScreenStrings get comparison;
  ResultScreenStrings get result;
  StrategyScreenStrings get strategies;
  AuthStrings get auth;
  CommonStrings get common;
  ErrorStrings get errors;
  StrategyCardStrings get strategyCard;
  ProgressBarStrings get progressBar;
  PinDisplayStrings get pinDisplay;
  TutorialStrings get tutorial;
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

abstract class ComparisonScreenStrings {
  const ComparisonScreenStrings();

  String get title;
  String get subtitle;
  String get selectionButton;
  String get confirmButton;
}

abstract class ResultScreenStrings {
  const ResultScreenStrings();

  String get correctTitle;
  String get wrongTitle;
  String get explanationTitle;
  String get reasonPrefix;
  String get currentRun;
  String get overallStats;
  String get correctFormat;
  String get nextButton;
}

abstract class StrategyScreenStrings {
  const StrategyScreenStrings();

  String get title;
  String get subtitle;
  String get nextGameButton;
  String get getPinButton;
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
  String get comparison;
  String get feedback;
  String get strategies;
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
  String get touchToContinue;
  String get screenSwipeInstruction;
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
