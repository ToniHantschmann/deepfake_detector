import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../config/app_config.dart';
import '../config/localization/string_types.dart';
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

// Hilfsfunktion zum Abrufen der lokalisierten String-Ressourcen
AppStrings getLocalizedStrings(BuildContext context) {
  final currentLocale = context.read<GameBloc>().state.locale;
  return AppConfig.getStrings(currentLocale);
}

// Methode zum Erstellen der implementierten Strategien basierend auf der aktuellen Sprache
List<Strategy> getImplementedStrategies(BuildContext context) {
  final strings = getLocalizedStrings(context).strategyCard;

  return [
    Strategy(
      id: 'face_manipulation',
      title: strings.faceManipulationTitle,
      description: strings.faceManipulationDescription,
      animation: const FaceManipulationAnimation(),
    ),
    Strategy(
      id: 'facial_features',
      title: strings.facialFeaturesTitle,
      description: strings.faceManipulationDescription,
      animation: const FacialFeaturesAnimation(),
    ),
    Strategy(
      id: 'eyes',
      title: strings.eyeTitle,
      description: strings.eyeDescription,
      animation: const EyeShadowAnimation(),
    ),
    Strategy(
      id: 'glasses',
      title: strings.glassesTitle,
      description: strings.glassesDescription,
      animation: const GlassesAnimation(),
    ),
    Strategy(
      id: 'facial_hair',
      title: strings.facialHairTitle,
      description: strings.facialHairDescription,
      animation: const FacialHairAnimation(),
    ),
    Strategy(
      id: 'moles',
      title: strings.molesTitle,
      description: strings.molesDescription,
      animation: const MolesAnimation(),
    ),
    Strategy(
      id: 'blinking',
      title: strings.blinkingTitle,
      description: strings.blinkingDescription,
      animation: const BlinkingAnimation(),
    ),
    Strategy(
      id: 'lip_sync',
      title: strings.lipSyncTitle,
      description: strings.lipSyncDescription,
      animation: const LipSyncAnimation(),
    ),
    Strategy(
      id: 'research',
      title: strings.researchTitle,
      description: strings.researchDescription,
      animation: const ResearchAnimation(),
    ),
  ];
}
