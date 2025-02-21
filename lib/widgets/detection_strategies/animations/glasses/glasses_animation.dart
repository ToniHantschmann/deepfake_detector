import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'glasses_painter.dart';

class GlassesAnimation extends StrategyAnimationBase {
  const GlassesAnimation({Key? key})
      : super(
          key: key,
        );

  @override
  State<GlassesAnimation> createState() => GlassesAnimationState();
}

class GlassesAnimationState
    extends StrategyAnimationBaseState<GlassesAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: GlassesPainter(
            animation.value,
            showingManipulated,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
