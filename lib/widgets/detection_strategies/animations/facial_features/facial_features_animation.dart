// lib/widgets/detection_strategies/animations/facial_features/facial_features_animation.dart

import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'facial_features_painter.dart';

class FacialFeaturesAnimation extends StrategyAnimationBase {
  const FacialFeaturesAnimation({Key? key}) : super(key: key);

  @override
  State<FacialFeaturesAnimation> createState() =>
      _FacialFeaturesAnimationState();
}

class _FacialFeaturesAnimationState
    extends StrategyAnimationBaseState<FacialFeaturesAnimation> {
  @override
  void initState() {
    super.initState();
    // Langsame Animation für natürlichere Übergänge
    animationController.duration = const Duration(milliseconds: 800);
  }

  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FacialFeaturesPainter(
            manipulationAmount: animation.value,
            showingManipulated: showingManipulated,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
