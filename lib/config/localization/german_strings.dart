// lib/config/localization/german_strings.dart

import 'string_types.dart';

class GermanStrings implements AppStrings {
  const GermanStrings();

  @override
  final introduction = const GermanIntroductionScreenStrings();
  @override
  final video = const GermanVideoScreenStrings();
  @override
  final comparison = const GermanComparisonScreenStrings();
  @override
  final result = const GermanResultScreenStrings();
  @override
  final strategies = const GermanStrategyScreenStrings();
  @override
  final auth = const GermanAuthStrings();
  @override
  final common = const GermanCommonStrings();
  @override
  final errors = const GermanErrorStrings();
  @override
  final strategyCard = const GermanStrategyCardStrings();
  @override
  final progressBar = const GermanProgressBarStrings();
  @override
  final pinDisplay = const GermanPinDisplayStrings();
  @override
  final tutorial = const GermanTutorialStrings();
}

class GermanIntroductionScreenStrings implements IntroductionScreenStrings {
  const GermanIntroductionScreenStrings();

  @override
  String get title => 'Deepfake Detektor';
  @override
  String get subtitle =>
      'Teste deine Fähigkeit, Deepfake-Videos in dieser interaktiven Herausforderung zu erkennen.';
  @override
  String get description =>
      'Dir werden zwei Videos gezeigt - ein echtes und ein Deepfake. Deine Aufgabe ist es, das gefälschte zu identifizieren.';
  @override
  String get startButton => 'Spiel starten';
  @override
  String get loginButton => 'Mit PIN einloggen';
  @override
  String get challenge => 'Erkennst du den Unterschied?';
}

class GermanVideoScreenStrings implements VideoScreenStrings {
  const GermanVideoScreenStrings();

  @override
  String get playButton => 'Abspielen';
  @override
  String get pauseButton => 'Pause';
  @override
  String get replayButton => 'Wiederholen';
  @override
  String get nextButton => 'Nächstes Video';
  @override
  String get backButton => 'Vorheriges Video';
  @override
  String get loading => 'Video wird geladen...';
  @override
  String get buffering => 'Pufferung...';
}

class GermanComparisonScreenStrings implements ComparisonScreenStrings {
  const GermanComparisonScreenStrings();

  @override
  String get title => 'Welches Video ist der Deepfake?';
  @override
  String get subtitle =>
      'Wähle das Video aus, das deiner Meinung nach künstlich erstellt wurde';
  @override
  String get selectionButton => 'Dies ist der Deepfake';
  @override
  String get confirmButton => 'Auswahl bestätigen';
}

class GermanResultScreenStrings implements ResultScreenStrings {
  const GermanResultScreenStrings();

  @override
  String get correctTitle => 'Richtige Entscheidung!';
  @override
  String get wrongTitle => 'Falsche Entscheidung!';
  @override
  String get explanationTitle => 'Warum dies ein Deepfake war:';
  @override
  String get reasonPrefix => 'Grund';
  @override
  String get currentRun => 'Aktueller Durchgang';
  @override
  String get overallStats => 'Gesamtstatistik';
  @override
  String get correctFormat => 'von';
  @override
  String get nextButton => 'Weiter';
}

class GermanStrategyScreenStrings implements StrategyScreenStrings {
  const GermanStrategyScreenStrings();

  @override
  String get title => 'Wie erkenne ich Deepfakes?';
  @override
  String get subtitle =>
      'Lerne die wichtigsten Strategien zur Erkennung von Deepfake-Videos';
  @override
  String get nextGameButton => 'Nächstes Spiel';
  @override
  String get getPinButton => 'PIN erhalten';
}

class GermanAuthStrings implements AuthStrings {
  const GermanAuthStrings();

  // Login Overlay
  @override
  String get loginTitle => 'PIN eingeben';
  @override
  String get loginSubtitle => 'Gib deinen 4-stelligen PIN ein, um fortzufahren';
  @override
  String get continueWithoutPin => 'Ohne PIN fortfahren';
  @override
  String get invalidPinError => 'Ungültiger PIN. Bitte versuche es erneut.';
  @override
  String get loginButtonText => 'Einloggen';
  @override
  String get closeLoginButton => 'Schließen';

  // PIN Display
  @override
  String get enterPinPrompt => 'Bitte gib deinen 4-stelligen PIN ein';
  @override
  String get pinPlaceholder => '•';
  @override
  String get pinInputError => 'PIN muss 4-stellig sein';

  // PIN Overlay
  @override
  String get pinTitle => 'Dein PIN';
  @override
  String get pinSubtitle =>
      'Speichere diesen PIN, um später auf deine Statistiken zuzugreifen';
  @override
  String get pinGeneratedTitle => 'PIN erfolgreich generiert';
  @override
  String get pinSavePrompt => 'Stelle sicher, dass du deinen PIN speicherst:';
  @override
  String get copyPin => 'PIN kopieren';
  @override
  String get pinCopied => 'PIN in die Zwischenablage kopiert';
  @override
  String get startNextGame => 'Nächstes Spiel starten';
  @override
  String get closeOverlay => 'Schließen';

  // Number Pad
  @override
  String get backspace => 'Löschen';
  @override
  String get clear => 'Leeren';
}

class GermanCommonStrings implements CommonStrings {
  const GermanCommonStrings();

  @override
  String get retry => 'Wiederholen';
  @override
  String get cancel => 'Abbrechen';
  @override
  String get confirm => 'Bestätigen';
  @override
  String get back => 'Zurück';
  @override
  String get next => 'Weiter';
  @override
  String get loading => 'Laden...';
}

class GermanErrorStrings implements ErrorStrings {
  const GermanErrorStrings();

  @override
  String get generalError => 'Ein Fehler ist aufgetreten';
  @override
  String get videoLoadError => 'Video konnte nicht geladen werden';
  @override
  String get invalidPin => 'Ungültiger PIN';
  @override
  String get networkError => 'Netzwerkverbindungsfehler';
  @override
  String get unknownError => 'Unbekannter Fehler aufgetreten';
  @override
  String get retryMessage => 'Bitte versuche es erneut';
}

class GermanProgressBarStrings implements ProgressBarStrings {
  const GermanProgressBarStrings();

  @override
  String get firstVideo => 'Video 1';
  @override
  String get secondVideo => 'Video 2';
  @override
  String get comparison => 'Vergleich';
  @override
  String get feedback => 'Feedback';
  @override
  String get strategies => 'Strategien';
}

class GermanPinDisplayStrings implements PinDisplayStrings {
  const GermanPinDisplayStrings();

  @override
  String get pinGeneratedTitle => 'PIN erfolgreich generiert';
  @override
  String get pinSavePrompt => 'Stelle sicher, dass du deinen PIN speicherst:';
  @override
  String get pinDisplayTitle => 'Dein PIN wurde generiert!';
  @override
  String get pinDisplayInstructions =>
      'Verwende diesen PIN, um bei deinem nächsten Besuch auf deine Statistiken zuzugreifen.';
  @override
  String get copyPin => 'PIN kopieren';
  @override
  String get pinCopied => 'PIN in die Zwischenablage kopiert';
  @override
  String get startNextGame => 'Nächstes Spiel starten';
  @override
  String get closeOverlay => 'Schließen';
}

class GermanTutorialStrings implements TutorialStrings {
  const GermanTutorialStrings();

  @override
  String get swipeTooltip => 'Wische, um weitere Strategien zu sehen!';
  @override
  String get touchToContinue => 'Tippe irgendwo, um fortzufahren';
  @override
  String get screenSwipeInstruction =>
      'Wische nach links oder rechts, um zwischen Bildschirmen zu navigieren!';
}

class GermanStrategyCardStrings implements StrategyCardStrings {
  const GermanStrategyCardStrings();

  // Face Manipulation
  @override
  String get faceManipulationTitle => 'Gesichtsmanipulation erkennen';
  @override
  String get faceManipulationDescription =>
      'Achte auf das Gesicht. Hochwertige DeepFake-Manipulationen zeigen oft subtile Artefakte und Verzerrungen in den Gesichtszügen.';
  @override
  String get faceManipulationOriginal => 'Originales Gesicht';
  @override
  String get faceManipulationModified => 'Manipuliertes Gesicht';
  @override
  String get faceManipulationIndicatorNormal => 'Natürliche Gesichtszüge';
  @override
  String get faceManipulationIndicatorManipulated =>
      'Manipulierte Gesichtszüge';

  // Facial Features Strategy
  @override
  String get facialFeaturesTitle => 'Altersmerkmale prüfen';
  @override
  String get facialFeaturesDescription =>
      'Achten Sie auf die Wangen und die Stirn. Wirkt die Haut zu glatt oder zu faltig? Ist das Alter der Haut ähnlich wie das Alter der Haare und Augen? DeepFakes können in einigen Dimensionen inkongruent sein.';
  @override
  String get facialFeaturesOriginal => 'Natürliche Alterung';
  @override
  String get facialFeaturesModified => 'Inkonsistente Alterung';
  @override
  String get facialFeaturesIndicatorNormal => 'Stimmige Altersmerkmale';
  @override
  String get facialFeaturesIndicatorManipulated =>
      'Widersprüchliche Alterungszeichen';

  // Blinking
  @override
  String get blinkingTitle => 'Natürliches Blinzeln';
  @override
  String get blinkingDescription =>
      'Menschen blinzeln typischerweise alle 4-6 Sekunden. Bei Deepfakes sind die Blinzelmuster oft unnatürlich oder fehlen komplett.';
  @override
  String get blinkingNatural => 'Natürlich';
  @override
  String get blinkingUnnatural => 'Unnatürlich';
  @override
  String get blinkingIndicatorNormal => 'Normales Blinzelintervall (~4s)';
  @override
  String get blinkingIndicatorFast => 'Unnatürlich schnelles Blinzeln';

  // Eye and Eyebrows
  @override
  String get eyeTitle => 'Augen und Augenbrauen';
  @override
  String get eyeDescription =>
      'Achte auf die Augen und Augenbrauen. Natürliche Schatten und Bewegungen sind in Deepfakes oft unvollständig oder fehlerhaft dargestellt.';
  @override
  String get eyeNatural => 'Natürlich';
  @override
  String get eyeArtificial => 'Künstlich';
  @override
  String get eyeIndicatorNormal => 'Realistische Augenschatten';
  @override
  String get eyeIndicatorArtificial => 'Fehlerhafte Schattierung';

  // Glasses Strategy
  @override
  String get glassesTitle => 'Brillenreflexionen';
  @override
  String get glassesDescription =>
      'Achte auf Brillenreflexionen. Bei Deepfakes sind Lichtreflexionen oft unnatürlich oder stimmen nicht mit der Szenenbeleuchtung überein.';
  @override
  String get glassesNatural => 'Natürlich';
  @override
  String get glassesArtificial => 'Künstlich';
  @override
  String get glassesIndicatorNormal => 'Realistische Lichtreflexionen';
  @override
  String get glassesIndicatorArtificial => 'Unstimmige Reflexionen';

  // Facial Hair
  @override
  String get facialHairTitle => 'Gesichtsbehaarung';
  @override
  String get facialHairDescription =>
      'Achte auf die Gesichtsbehaarung. Deepfakes haben oft Schwierigkeiten, Bart, Schnurrbart oder Koteletten natürlich darzustellen und zu animieren.';
  @override
  String get facialHairNatural => 'Natürlich';
  @override
  String get facialHairArtificial => 'Künstlich';
  @override
  String get facialHairIndicatorNormal => 'Natürliche Bartstruktur';
  @override
  String get facialHairIndicatorArtificial => 'Unnatürliche Bartdarstellung';

  // Moles/Birthmarks
  @override
  String get molesTitle => 'Leberflecken-Analyse';
  @override
  String get molesDescription =>
      'Achte auf Leberflecken und Muttermale. Deepfakes haben oft Schwierigkeiten, diese Details konsistent darzustellen oder sie verschwinden komplett zwischen den Frames.';
  @override
  String get molesNatural => 'Natürlich';
  @override
  String get molesArtificial => 'Künstlich';
  @override
  String get molesIndicatorNormal => 'Konsistente Leberflecken';
  @override
  String get molesIndicatorArtificial =>
      'Inkonsistente oder fehlende Leberflecken';

  // Lip Sync
  @override
  String get lipSyncTitle => 'Lippensynchronisation';
  @override
  String get lipSyncDescription =>
      'Achte auf die Lippenbewegungen. Bei DeepFakes sind die Lippenbewegungen oft nicht perfekt mit der Sprache synchronisiert oder erscheinen unnatürlich.';
  @override
  String get lipSyncNatural => 'Synchron';
  @override
  String get lipSyncArtificial => 'Asynchron';
  @override
  String get lipSyncIndicatorNormal => 'Natürliche Lippenbewegung';
  @override
  String get lipSyncIndicatorArtificial => 'Verzögerte Lippenbewegung';

  // Internet Research
  @override
  String get researchTitle => 'Internet-Recherche';
  @override
  String get researchDescription =>
      'Überprüfe im Zweifelsfall die Authentizität eines Videos, indem du online nach der Quelle und dem Kontext suchst. Verwende vertrauenswürdige Faktenprüfungs-Websites und Rückwärtsbildsuche-Tools.';
  @override
  String get researchStepSearch => 'Online suchen';
  @override
  String get researchStepVerify => 'Quellen überprüfen';
  @override
  String get researchStepAnalyze => 'Kontext analysieren';
  @override
  String get researchButtonText => 'Recherche starten';
  @override
  String get researchTip => 'Denke daran, mehrere Quellen abzugleichen';
  @override
  String get researchStatusNone => 'Recherche nicht gestartet';
  @override
  String get researchStatusInProgress => 'Recherchiere...';
  @override
  String get researchStatusComplete => 'Recherche abgeschlossen';

  // General Strategy UI
  @override
  String get toggleOriginal => 'Original';
  @override
  String get toggleManipulated => 'Manipuliert';
  @override
  String get indicatorNormal => 'Natürlich';
  @override
  String get indicatorArtificial => 'Künstlich';
}
