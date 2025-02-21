// lib/widgets/detection_strategies/animations/moles/moles_animation.dart

import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'moles_painter.dart';

class MolesAnimation extends StrategyAnimationBase {
  const MolesAnimation({Key? key})
      : super(
          key: key,
        );

  @override
  State<MolesAnimation> createState() => MolesAnimationState();
}

class MolesAnimationState extends StrategyAnimationBaseState<MolesAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FaceMolesPainter(animation.value),
          size: const Size(300, 300),
        );
      },
    );
  }
}
