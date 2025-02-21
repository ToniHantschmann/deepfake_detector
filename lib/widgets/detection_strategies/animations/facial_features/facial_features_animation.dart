import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'facial_features_painter.dart';

class FacialFeaturesAnimation extends StrategyAnimationBase {
  const FacialFeaturesAnimation({Key? key}) : super(key: key);

  @override
  State<FacialFeaturesAnimation> createState() =>
      FacialFeaturesAnimationState();
}

class FacialFeaturesAnimationState
    extends StrategyAnimationBaseState<FacialFeaturesAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FacialFeaturesPainter(animation.value),
        );
      },
    );
  }
}
