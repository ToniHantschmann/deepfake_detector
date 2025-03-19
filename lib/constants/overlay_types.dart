enum OverlayType {
  strategySwipe,
  videoTap,
  pinGenerate,
  confidenceSurvey,
}

extension OverlayTypeExtension on OverlayType {
  bool get isTutorial {
    return [
      OverlayType.strategySwipe,
      OverlayType.videoTap,
      OverlayType.pinGenerate,
    ].contains(this);
  }

  bool get isSurvey {
    return [
      OverlayType.confidenceSurvey,
    ].contains(this);
  }
}
