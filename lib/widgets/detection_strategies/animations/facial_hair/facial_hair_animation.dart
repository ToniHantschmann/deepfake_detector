import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'facial_hair_painter.dart';

class FacialHairAnimation extends StrategyAnimationBase {
  const FacialHairAnimation({Key? key})
      : super(
          key: key,
        );
  @override
  State<FacialHairAnimation> createState() => FacialHairAnimationState();
}

class FacialHairAnimationState
    extends StrategyAnimationBaseState<FacialHairAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FacialHairPainter(animation.value),
          size: const Size(300, 300),
        );
      },
    );
  }
}
