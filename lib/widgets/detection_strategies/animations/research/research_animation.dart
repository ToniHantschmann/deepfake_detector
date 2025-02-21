// lib/widgets/detection_strategies/animations/research/research_animation.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../common/animation_base.dart';
import 'research_painter.dart';

class ResearchAnimation extends StrategyAnimationBase {
  const ResearchAnimation({Key? key}) : super(key: key);

  @override
  State<ResearchAnimation> createState() => ResearchAnimationState();
}

class ResearchAnimationState
    extends StrategyAnimationBaseState<ResearchAnimation> {
  int _currentStep = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    // Überschreibe die Standard-Animationsdauer
    animationController.duration = const Duration(milliseconds: 1500);
  }

  @override
  void updateMode(bool manipulated) {
    super.updateMode(manipulated);
    if (manipulated) {
      _startStepAnimation();
    } else {
      _stopStepAnimation();
    }
  }

  void _startStepAnimation() {
    _stopStepAnimation();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      setState(() {
        _currentStep = (_currentStep + 1) % 3;
      });
      animationController.forward(from: 0);
    });
    animationController.forward(from: 0);
  }

  void _stopStepAnimation() {
    _stepTimer?.cancel();
    _stepTimer = null;
    setState(() {
      _currentStep = 0;
    });
    animationController.reset();
  }

  @override
  void dispose() {
    _stopStepAnimation();
    super.dispose();
  }

  @override
  Widget buildAnimation() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ResearchPainter(
            progress: animation.value,
            currentStep: _currentStep,
            isActive: showingManipulated,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
