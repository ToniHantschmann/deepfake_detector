import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../widgets/detection_strategies/animations/blinking/blinking_animation.dart';
import '../widgets/detection_strategies/animations/face_manipulation/face_manipulation_animation.dart';
import '../widgets/detection_strategies/animations/facial_features/facial_features_animation.dart';
import '../widgets/detection_strategies/animations/eye_shadow/eye_shadow_animation.dart';
import '../widgets/detection_strategies/animations/glasses/glasses_animation.dart';
import '../widgets/detection_strategies/animations/facial_hair/facial_hair_animation.dart';
import '../widgets/detection_strategies/animations/moles/moles_animation.dart';
import '../widgets/detection_strategies/animations/lip/lip_animation.dart';
import '../widgets/detection_strategies/animations/research/research_animation.dart';

class Strategy {
  final String id;
  final String title;
  final String description;
  final Widget animation;

  const Strategy({
    required this.id,
    required this.title,
    required this.description,
    required this.animation,
  });

  // Factory für Dummy-Strategien
  factory Strategy.dummy({
    required String id,
    required String title,
  }) {
    return Strategy(
      id: id,
      title: title,
      description:
          'This is a dummy strategy description for $title. It will be replaced with real content later.',
      animation: const SizedBox(
        height: 200,
        child: Center(
          child: Text('Dummy Animation Placeholder'),
        ),
      ),
    );
  }
}

final List<Strategy> implementedStrategies = [
  Strategy(
    id: 'face_manipulation',
    title: AppConfig.strings.strategyCard.faceManipulationTitle,
    description: AppConfig.strings.strategyCard.faceManipulationDescription,
    animation: const FaceManipulationAnimation(),
  ),
  Strategy(
    id: 'facial_features',
    title: AppConfig.strings.strategyCard.facialFeaturesTitle,
    description: AppConfig.strings.strategyCard.facialFeaturesDescription,
    animation: const FacialFeaturesAnimation(),
  ),
  Strategy(
    id: 'eyes',
    title: AppConfig.strings.strategyCard.eyeTitle,
    description: AppConfig.strings.strategyCard.eyeDescription,
    animation: const EyeShadowAnimation(),
  ),
  Strategy(
    id: 'glasses',
    title: AppConfig.strings.strategyCard.glassesTitle,
    description: AppConfig.strings.strategyCard.glassesDescription,
    animation: const GlassesAnimation(),
  ),
  Strategy(
    id: 'facial_hair',
    title: AppConfig.strings.strategyCard.facialHairTitle,
    description: AppConfig.strings.strategyCard.facialHairDescription,
    animation: const FacialHairAnimation(),
  ),
  Strategy(
    id: 'moles',
    title: AppConfig.strings.strategyCard.molesTitle,
    description: AppConfig.strings.strategyCard.molesDescription,
    animation: const MolesAnimation(),
  ),
  Strategy(
    id: 'blinking',
    title: AppConfig.strings.strategyCard.blinkingTitle,
    description: AppConfig.strings.strategyCard.blinkingDescription,
    animation: const BlinkingAnimation(),
  ),
  Strategy(
    id: 'lip_sync',
    title: AppConfig.strings.strategyCard.lipSyncTitle,
    description: AppConfig.strings.strategyCard.lipSyncDescription,
    animation: const LipSyncAnimation(),
  ),
  /*
  Strategy(
    id: 'research',
    title: AppConfig.strings.strategyCard.researchTitle,
    description: AppConfig.strings.strategyCard.researchDescription,
    animation: const ResearchAnimation(),
  ),
  */
];
