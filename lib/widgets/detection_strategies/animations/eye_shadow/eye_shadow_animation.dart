import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'eye_shadow_painter.dart';

class EyeShadowAnimation extends StrategyAnimationBase {
  const EyeShadowAnimation({Key? key}) : super(key: key);

  @override
  State<EyeShadowAnimation> createState() => EyeShadowAnimationState();
}

class EyeShadowAnimationState
    extends StrategyAnimationBaseState<EyeShadowAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: EyeShadowPainter(
            manipulationAmount: animation.value,
            showDetails: true,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
