import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'lip_painter.dart';

class LipSyncAnimation extends StrategyAnimationBase {
  const LipSyncAnimation({Key? key}) : super(key: key);

  @override
  State<LipSyncAnimation> createState() => LipSyncAnimationState();
}

class LipSyncAnimationState
    extends StrategyAnimationBaseState<LipSyncAnimation> {
  @override
  void initState() {
    super.initState();
    // Anpassung der Animations-Geschwindigkeit je nach Modus
    animationController.duration = const Duration(milliseconds: 500);
  }

  @override
  void updateMode(bool manipulated) {
    super.updateMode(manipulated);
    // Aktualisiere die Animations-Geschwindigkeit
    animationController.duration = Duration(
      milliseconds: manipulated ? 200 : 500,
    );
    startAnimation();
  }

  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: LipSyncPainter(
            animation.value,
            showingManipulated,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
