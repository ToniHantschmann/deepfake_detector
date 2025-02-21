import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'face_manipulation_painter.dart';

class FaceManipulationAnimation extends StrategyAnimationBase {
  const FaceManipulationAnimation({Key? key}) : super(key: key);

  @override
  State<FaceManipulationAnimation> createState() =>
      FaceManipulationAnimationState();
}

class FaceManipulationAnimationState
    extends StrategyAnimationBaseState<FaceManipulationAnimation> {
  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FaceManipulationPainter(animation.value),
        );
      },
    );
  }
}
