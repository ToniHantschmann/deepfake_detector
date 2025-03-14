// lib/config/localization/english_strings.dart

import 'string_types.dart';
import 'english_reasons_strings.dart';

class EnglishStrings implements AppStrings {
  const EnglishStrings();

  @override
  final introduction = const EnglishIntroductionScreenStrings();
  @override
  final video = const EnglishVideoScreenStrings();
  @override
  final comparison = const EnglishDecisionScreenStrings();
  @override
  final result = const EnglishResultScreenStrings();
  @override
  final strategies = const EnglishStrategyScreenStrings();
  @override
  final auth = const EnglishAuthStrings();
  @override
  final common = const EnglishCommonStrings();
  @override
  final errors = const EnglishErrorStrings();
  @override
  final strategyCard = const EnglishStrategyCardStrings();
  @override
  final progressBar = const EnglishProgressBarStrings();
  @override
  final pinDisplay = const EnglishPinDisplayStrings();
  @override
  final tutorial = const EnglishTutorialStrings();
  @override
  final deepfakeReasons = const EnglishDeepfakeReasonStrings();
  @override
  final videoPlayer = const EnglishVideoPlayerStrings();
}

class EnglishIntroductionScreenStrings implements IntroductionScreenStrings {
  const EnglishIntroductionScreenStrings();

  @override
  String get title => 'Deepfake Detector';
  @override
  String get subtitle => 'Test how good your AI detection skills are.';
  @override
  String get description =>
      "You are shown a video - your task is to decide whether the video is a deepfake.";
  @override
  String get startButton => 'Start Game';
  @override
  String get loginButton => 'Login with PIN';
  @override
  String get challenge => 'Can you spot the difference?';
}

class EnglishVideoScreenStrings implements VideoScreenStrings {
  const EnglishVideoScreenStrings();

  @override
  String get playButton => 'Play';
  @override
  String get pauseButton => 'Pause';
  @override
  String get replayButton => 'Replay';
  @override
  String get nextButton => 'Next Video';
  @override
  String get backButton => 'Previous Video';
  @override
  String get loading => 'Loading video...';
  @override
  String get buffering => 'Buffering...';
}

class EnglishDecisionScreenStrings implements DecisionScreenStrings {
  const EnglishDecisionScreenStrings();

  @override
  String get title => 'Is this video a deepfake?';
  @override
  String get subtitle =>
      'Decide whether the video shown has been artificially manipulated.';
  @override
  String get selectionButton => 'This is the Deepfake';
  @override
  String get confirmButton => 'Confirm Selection';

  @override
  String get realButtonLabel => 'Real';
  @override
  String get deepfakeButtonLabel => 'Deepfake';
  @override
  String get questionLabel => 'Is this video manipulated?';
  @override
  String get instructionLabel => 'Examine the video carefully';
}

class EnglishResultScreenStrings implements ResultScreenStrings {
  const EnglishResultScreenStrings();

  @override
  String get correctTitle => 'Correct decision!';
  @override
  String get wrongTitle => 'Wrong decision!';
  @override
  String get explanationTitle => 'Why this was a deepfake:';
  @override
  String get reasonPrefix => 'Reason';
  @override
  String get currentRun => 'Current Run';
  @override
  String get overallStats => 'Overall Statistics';
  @override
  String get correctFormat => 'of';
  @override
  String get nextButton => 'Next';
  @override
  String get videoComparisonTitle => 'Video Comparison';
  @override
  String get shownVideoTitle => 'Shown Video';
  @override
  String get comparisonVideoTitle => 'Comparison Video';
  @override
  String get deepfakeIndicator => 'Deepfake';
  @override
  String get realVideoIndicator => 'Real Video';
  @override
  String get watchVideoButton => 'Watch Video';
  @override
  String get yourDecision => 'Your Decision';
}

class EnglishStrategyScreenStrings implements StrategyScreenStrings {
  const EnglishStrategyScreenStrings();

  @override
  String get title => 'How to detect Deepfakes?';
  @override
  String get subtitle => 'Learn the key strategies to identify deepfake videos';
  @override
  String get nextGameButton => 'Next Game';
  @override
  String get getPinButton => 'Get PIN';
  @override
  String get statsButton => 'Go to statistics';
}

class EnglishAuthStrings implements AuthStrings {
  const EnglishAuthStrings();

  // Login Overlay
  @override
  String get loginTitle => 'Enter PIN';
  @override
  String get loginSubtitle => 'Enter your 4-digit PIN to continue';
  @override
  String get continueWithoutPin => 'Continue without PIN';
  @override
  String get invalidPinError => 'Invalid PIN. Please try again.';
  @override
  String get loginButtonText => 'Login';
  @override
  String get closeLoginButton => 'Close';

  // PIN Display
  @override
  String get enterPinPrompt => 'Please enter your 4-digit PIN';
  @override
  String get pinPlaceholder => '•';
  @override
  String get pinInputError => 'PIN must be 4 digits';

  // PIN Overlay
  @override
  String get pinTitle => 'Your PIN';
  @override
  String get pinSubtitle => 'Save this PIN to access your statistics later';
  @override
  String get pinGeneratedTitle => 'PIN Generated Successfully';
  @override
  String get pinSavePrompt => 'Make sure to save your PIN:';
  @override
  String get copyPin => 'Copy PIN';
  @override
  String get pinCopied => 'PIN copied to clipboard';
  @override
  String get startNextGame => 'Start Next Game';
  @override
  String get closeOverlay => 'Close';

  // Number Pad
  @override
  String get backspace => 'Backspace';
  @override
  String get clear => 'Clear';
}

class EnglishCommonStrings implements CommonStrings {
  const EnglishCommonStrings();

  @override
  String get retry => 'Retry';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get loading => 'Loading...';
}

class EnglishErrorStrings implements ErrorStrings {
  const EnglishErrorStrings();

  @override
  String get generalError => 'An error occurred';
  @override
  String get videoLoadError => 'Failed to load video';
  @override
  String get invalidPin => 'Invalid PIN';
  @override
  String get networkError => 'Network connection error';
  @override
  String get unknownError => 'Unknown error occurred';
  @override
  String get retryMessage => 'Please try again';
}

class EnglishProgressBarStrings implements ProgressBarStrings {
  const EnglishProgressBarStrings();

  @override
  String get firstVideo => 'Video';
  @override
  String get secondVideo => 'Video 2';
  @override
  String get decision => 'Decision';
  @override
  String get result => 'Comparison';
  @override
  String get strategies => 'Strategies';
  @override
  String get statistics => 'Statistics';
}

class EnglishPinDisplayStrings implements PinDisplayStrings {
  const EnglishPinDisplayStrings();

  @override
  String get pinGeneratedTitle => 'PIN Generated Successfully';
  @override
  String get pinSavePrompt => 'Make sure to save your PIN:';
  @override
  String get pinDisplayTitle => 'Your PIN has been generated!';
  @override
  String get pinDisplayInstructions =>
      'Use this PIN to access your statistics on your next visit.';
  @override
  String get copyPin => 'Copy PIN';
  @override
  String get pinCopied => 'PIN copied to clipboard';
  @override
  String get startNextGame => 'Start Next Game';
  @override
  String get closeOverlay => 'Close';
}

class EnglishTutorialStrings implements TutorialStrings {
  const EnglishTutorialStrings();

  @override
  String get swipeTooltip => 'Swipe to see more strategies!';
  @override
  String get touchToContinue => 'Touch anywhere to continue';
  @override
  String get screenSwipeInstruction =>
      'Swipe left or right to navigate between screens!';
}

class EnglishVideoPlayerStrings implements VideoPlayerStrings {
  const EnglishVideoPlayerStrings();

  @override
  String get deepfakeLabel => 'Deepfake Video';
  @override
  String get realLabel => 'Real Video';
}

class EnglishStrategyCardStrings implements StrategyCardStrings {
  const EnglishStrategyCardStrings();

  // Face Manipulation
  @override
  String get faceManipulationTitle => 'Detect Face Manipulation';
  @override
  String get faceManipulationDescription =>
      'Watch out for the face. High-quality deepfake manipulations often show subtle artifacts and distortions in facial features.';
  @override
  String get faceManipulationOriginal => 'Original Face';
  @override
  String get faceManipulationModified => 'Manipulated Face';
  @override
  String get faceManipulationIndicatorNormal => 'Natural facial features';
  @override
  String get faceManipulationIndicatorManipulated =>
      'Manipulated facial features';

  // Facial Features Strategy
  @override
  String get facialFeaturesTitle => 'Check Aging Features';
  @override
  String get facialFeaturesDescription =>
      'Pay attention to the cheeks and forehead. Does the skin look too smooth or too wrinkled? Is the age of the skin similar to the age of the hair and eyes? Deepfakes can be incongruent in some dimensions.';
  @override
  String get facialFeaturesOriginal => 'Natural Aging';
  @override
  String get facialFeaturesModified => 'Inconsistent Aging';
  @override
  String get facialFeaturesIndicatorNormal => 'Coherent aging features';
  @override
  String get facialFeaturesIndicatorManipulated => 'Contradictory aging signs';

  // Blinking
  @override
  String get blinkingTitle => 'Natural Blinking';
  @override
  String get blinkingDescription =>
      'Humans typically blink every 4-6 seconds. In deepfakes, blinking patterns are often unnatural or missing completely.';
  @override
  String get blinkingNatural => 'Natural';
  @override
  String get blinkingUnnatural => 'Unnatural';
  @override
  String get blinkingIndicatorNormal => 'Normal blinking interval (~4s)';
  @override
  String get blinkingIndicatorFast => 'Unnatural fast blinking';

  // Eye and Eyebrows
  @override
  String get eyeTitle => 'Eyes and Eyebrows';
  @override
  String get eyeDescription =>
      'Pay attention to the eyes and eyebrows. Natural shadows and movements are often incompletely or incorrectly represented in deepfakes.';
  @override
  String get eyeNatural => 'Natural';
  @override
  String get eyeArtificial => 'Artificial';
  @override
  String get eyeIndicatorNormal => 'Realistic eye shadows';
  @override
  String get eyeIndicatorArtificial => 'Faulty shadowing';

  // Glasses Strategy
  @override
  String get glassesTitle => 'Glasses Reflections';
  @override
  String get glassesDescription =>
      'Watch for reflections in glasses. In deepfakes, light reflections are often unnatural or inconsistent with scene lighting.';
  @override
  String get glassesNatural => 'Natural';
  @override
  String get glassesArtificial => 'Artificial';
  @override
  String get glassesIndicatorNormal => 'Realistic light reflections';
  @override
  String get glassesIndicatorArtificial => 'Inconsistent reflections';

  // Facial Hair
  @override
  String get facialHairTitle => 'Facial Hair';
  @override
  String get facialHairDescription =>
      'Pay attention to facial hair. Deepfakes often struggle to naturally represent and animate beards, mustaches, or sideburns.';
  @override
  String get facialHairNatural => 'Natural';
  @override
  String get facialHairArtificial => 'Artificial';
  @override
  String get facialHairIndicatorNormal => 'Natural beard structure';
  @override
  String get facialHairIndicatorArtificial => 'Unnatural beard representation';

  // Moles/Birthmarks
  @override
  String get molesTitle => 'Moles Analysis';
  @override
  String get molesDescription =>
      'Watch for moles and birthmarks. Deepfakes often struggle to consistently display these details or they disappear completely between frames.';
  @override
  String get molesNatural => 'Natural';
  @override
  String get molesArtificial => 'Artificial';
  @override
  String get molesIndicatorNormal => 'Consistent moles';
  @override
  String get molesIndicatorArtificial => 'Inconsistent or missing moles';

  // Lip Sync
  @override
  String get lipSyncTitle => 'Lip Synchronization';
  @override
  String get lipSyncDescription =>
      'Watch the lip movements. In deepfakes, lip movements are often not perfectly synchronized with speech or appear unnatural.';
  @override
  String get lipSyncNatural => 'Synchronized';
  @override
  String get lipSyncArtificial => 'Asynchronous';
  @override
  String get lipSyncIndicatorNormal => 'Natural lip movement';
  @override
  String get lipSyncIndicatorArtificial => 'Delayed lip movement';

  // Internet Research
  @override
  String get researchTitle => 'Internet Research';
  @override
  String get researchDescription =>
      'When in doubt, verify the authenticity of a video by searching for its source and context online. Use trusted fact-checking websites and reverse image search tools.';
  @override
  String get researchStepSearch => 'Search Online';
  @override
  String get researchStepVerify => 'Verify Sources';
  @override
  String get researchStepAnalyze => 'Analyze Context';
  @override
  String get researchButtonText => 'Start Research';
  @override
  String get researchTip => 'Remember to cross-reference multiple sources';
  @override
  String get researchStatusNone => 'Research not started';
  @override
  String get researchStatusInProgress => 'Researching...';
  @override
  String get researchStatusComplete => 'Research complete';

  // General Strategy UI
  @override
  String get toggleOriginal => 'Original';
  @override
  String get toggleManipulated => 'Manipulated';
  @override
  String get indicatorNormal => 'Natural';
  @override
  String get indicatorArtificial => 'Artificial';
}
