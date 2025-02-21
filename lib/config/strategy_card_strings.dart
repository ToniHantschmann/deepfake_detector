// lib/config/app_config.dart

class StrategyCardStrings {
  const StrategyCardStrings();

  // Face Manipulation
  final String faceManipulationTitle = 'Gesichtsmanipulation erkennen';
  final String faceManipulationDescription =
      'Achten Sie auf das Gesicht. Hochwertige DeepFake-Manipulationen zeigen oft subtile Artefakte und Verzerrungen in den Gesichtszügen.';
  final String faceManipulationOriginal = 'Originales Gesicht';
  final String faceManipulationModified = 'Manipuliertes Gesicht';
  final String faceManipulationIndicatorNormal = 'Natürliche Gesichtszüge';
  final String faceManipulationIndicatorManipulated =
      'Manipulierte Gesichtszüge';

  // Blinking
  final String blinkingTitle = 'Natürliches Blinzeln';
  final String blinkingDescription =
      'Menschen blinzeln typischerweise alle 4-6 Sekunden. Bei Deepfakes sind die Blinzelmuster oft unnatürlich oder fehlen komplett.';
  final String blinkingNatural = 'Natürlich';
  final String blinkingUnnatural = 'Unnatürlich';
  final String blinkingIndicatorNormal = 'Normales Blinzelintervall (~ 4s)';
  final String blinkingIndicatorFast = 'Unnatürlich schnelles Blinzeln';

  // Skin Texture
  final String skinTextureTitle = 'Hauttextur-Analyse';
  final String skinTextureDescription =
      'Achten Sie auf Unstimmigkeiten in der Hauttextur. Deepfakes zeigen oft unnatürliche Glättung oder Alterungsmuster, die nicht mit anderen Gesichtsmerkmalen übereinstimmen.';
  final String skinTextureNatural = 'Natürlich';
  final String skinTextureArtificial = 'Künstlich';
  final String skinTextureIndicatorNormal = 'Realistische Hauttextur';
  final String skinTextureIndicatorArtificial = 'Inkonsistente Hautstruktur';

  // Eye and Eyebrows
  final String eyeTitle = 'Augen und Augenbrauen';
  final String eyeDescription =
      'Achten Sie auf die Augen und Augenbrauen. Natürliche Schatten und Bewegungen sind in Deepfakes oft unvollständig oder fehlerhaft dargestellt.';
  final String eyeNatural = 'Natürlich';
  final String eyeArtificial = 'Künstlich';
  final String eyeIndicatorNormal = 'Realistische Augenschatten';
  final String eyeIndicatorArtificial = 'Fehlerhafte Schattierung';

  // Glasses Strategy
  final String glassesTitle = 'Brillenreflexionen';
  final String glassesDescription =
      'Achten Sie auf Brillenreflexionen. Bei Deepfakes sind Lichtreflexionen oft unnatürlich oder stimmen nicht mit der Szenenbeleuchtung überein.';
  final String glassesNatural = 'Natürlich';
  final String glassesArtificial = 'Künstlich';
  final String glassesIndicatorNormal = 'Realistische Lichtreflexionen';
  final String glassesIndicatorArtificial = 'Unstimmige Reflexionen';

  // General Strategy UI
  final String toggleOriginal = 'Original';
  final String toggleManipulated = 'Manipuliert';
  final String indicatorNormal = 'Natürlich';
  final String indicatorArtificial = 'Künstlich';

  // Facial Hair
  final String facialHairTitle = 'Gesichtsbehaarung';
  final String facialHairDescription =
      'Achten Sie auf die Gesichtsbehaarung. Deepfakes haben oft Schwierigkeiten, Bart, Schnurrbart oder Koteletten natürlich darzustellen und zu animieren.';
  final String facialHairNatural = 'Natürlich';
  final String facialHairArtificial = 'Künstlich';
  final String facialHairIndicatorNormal = 'Natürliche Bartstruktur';
  final String facialHairIndicatorArtificial = 'Unnatürliche Bartdarstellung';

  // Moles/Birthmarks
  final String molesTitle = 'Leberflecken-Analyse';
  final String molesDescription =
      'Achten Sie auf Leberflecken und Muttermale. Deepfakes haben oft Schwierigkeiten, diese Details konsistent darzustellen oder sie verschwinden komplett zwischen den Frames.';
  final String molesNatural = 'Natürlich';
  final String molesArtificial = 'Künstlich';
  final String molesIndicatorNormal = 'Konsistente Leberflecken';
  final String molesIndicatorArtificial =
      'Inkonsistente oder fehlende Leberflecken';

  // Lip Sync
  final String lipSyncTitle = 'Lippensynchronisation';
  final String lipSyncDescription =
      'Achten Sie auf die Lippenbewegungen. Bei DeepFakes sind die Lippenbewegungen oft nicht perfekt mit der Sprache synchronisiert oder erscheinen unnatürlich.';
  final String lipSyncNatural = 'Synchron';
  final String lipSyncArtificial = 'Asynchron';
  final String lipSyncIndicatorNormal = 'Natürliche Lippenbewegung';
  final String lipSyncIndicatorArtificial = 'Verzögerte Lippenbewegung';

  // Internet Research
  final String researchTitle = 'Internet Research';
  final String researchDescription =
      'When in doubt, verify the authenticity of a video by searching for its source and context online. Use trusted fact-checking websites and reverse image search tools.';
  final String researchStepSearch = 'Search Online';
  final String researchStepVerify = 'Verify Sources';
  final String researchStepAnalyze = 'Analyze Context';
  final String researchButtonText = 'Start Research';
  final String researchTip = 'Remember to cross-reference multiple sources';
  final String researchStatusNone = 'Research not started';
  final String researchStatusInProgress = 'Researching...';
  final String researchStatusComplete = 'Research complete';
}
