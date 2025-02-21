import 'dart:async';

import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'blinking_painter.dart';

class BlinkingAnimation extends StrategyAnimationBase {
  const BlinkingAnimation({Key? key}) : super(key: key);

  @override
  State<BlinkingAnimation> createState() => BlinkingAnimationState();
}

class BlinkingAnimationState
    extends StrategyAnimationBaseState<BlinkingAnimation> {
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    // Überschreibe die Standard-Animationsdauer für schnelleres Blinzeln
    animationController.duration = const Duration(milliseconds: 100);
    _startBlinkTimer();
  }

  void _startBlinkTimer() {
    _stopBlinkTimer();

    final interval = showingManipulated
        ? const Duration(milliseconds: 800) // Unnatürlich schnelles Blinzeln
        : const Duration(seconds: 4); // Natürliches Blinzeln

    _blinkTimer = Timer.periodic(interval, (timer) {
      if (!mounted) return;

      // Führe Blinzel-Animation aus
      animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          animationController.reverse();
        });
      });
    });
  }

  void _stopBlinkTimer() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }

  @override
  void updateMode(bool manipulated) {
    super.updateMode(manipulated);
    _startBlinkTimer(); // Starte neuen Timer mit angepasstem Intervall
  }

  @override
  void dispose() {
    _stopBlinkTimer();
    super.dispose();
  }

  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BlinkingPainter(1.0 - animation.value),
          size: const Size(300, 300),
        );
      },
    );
  }
}
