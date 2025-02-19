import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../widgets/detection_strategies/animations/blinking_animation.dart';
import '../widgets/detection_strategies/animations/skin_texture_animation.dart';
import '../widgets/detection_strategies/animations/face_manipulation_animation.dart';

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

// Eine globale Liste von Dummy-Strategien für die Entwicklung
final List<Strategy> dummyStrategies = [
  Strategy.dummy(id: 'blinking', title: 'Natural Blinking Pattern'),
  Strategy.dummy(id: 'skin', title: 'Skin Texture Analysis'),
  Strategy.dummy(id: 'voice', title: 'Voice Synchronization'),
  Strategy.dummy(id: 'background', title: 'Background Consistency'),
  Strategy.dummy(id: 'expressions', title: 'Facial Expressions'),
];

final List<Strategy> implementedStrategies = [
  Strategy(
    id: 'blinking',
    title: AppConfig.strings.strategyCard.blinkingTitle,
    description: AppConfig.strings.strategyCard.blinkingDescription,
    animation: const BlinkingAnimation(),
  ),
  Strategy(
    id: 'skin',
    title: AppConfig.strings.strategyCard.skinTextureTitle,
    description: AppConfig.strings.strategyCard.skinTextureDescription,
    animation: const SkinTextureAnimation(),
  ),
  Strategy(
    id: 'face_manipulation',
    title: AppConfig.strings.strategyCard.faceManipulationTitle,
    description: AppConfig.strings.strategyCard.faceManipulationDescription,
    animation: const FaceManipulationAnimation(),
  ),
];
