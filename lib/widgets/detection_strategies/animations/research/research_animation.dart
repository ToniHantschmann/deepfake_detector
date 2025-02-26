// lib/widgets/detection_strategies/animations/research/research_animation.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../common/animation_base_generic.dart';
import 'research_painter.dart';

class ResearchAnimation extends GenericStrategyAnimationBase {
  const ResearchAnimation({Key? key}) : super(key: key);

  @override
  State<ResearchAnimation> createState() => _ResearchAnimationState();
}

class _ResearchAnimationState
    extends GenericStrategyAnimationBaseState<ResearchAnimation> {
  int _currentStep = 0;
  Timer? _stepTimer;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    animationController.duration = const Duration(milliseconds: 1500);
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _isTimerActive = false;
    if (_stepTimer != null) {
      _stepTimer!.cancel();
      _stepTimer = null;
    }
  }

  @override
  void updateActiveState(bool active) {
    // Erst die Basis-Klasse aktualisieren (UI-Status, etc.)
    super.updateActiveState(active);

    // Dann die spezifische Timer-Logik
    if (active) {
      _scheduleTimer();
    } else {
      _cancelTimer();
    }
  }

  // Timer sicher auf den nächsten Frame planen
  void _scheduleTimer() {
    if (_isTimerActive) return;

    _isTimerActive = true;

    // Timer auf den nächsten Frame verschieben
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isTimerActive = false;
        return;
      }
      _startStepTimer();
    });
  }

  void _startStepTimer() {
    // Sicherheitsüberprüfung
    if (!mounted || !_isTimerActive) return;

    // Timer bereits vorhanden
    if (_stepTimer != null) {
      _stepTimer!.cancel();
      _stepTimer = null;
    }

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        _isTimerActive = false;
        return;
      }

      // Aktualisiere den Schritt auf sicherem Weg
      final nextStep = (_currentStep + 1) % 3;

      // Direkte Zustandsänderung mit setState auf nächstem Frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isTimerActive) {
          setState(() {
            _currentStep = nextStep;
          });

          // Animation neu starten
          if (mounted) {
            animationController.forward(from: 0);
          }
        }
      });
    });

    // Initial Animation starten
    if (mounted) {
      animationController.forward(from: 0);
    }
  }

  @override
  void pauseAnimation() {
    super.pauseAnimation();
    // Zusätzliche Logik: Timer pausieren
    _cancelTimer();
  }

  @override
  void resumeAnimation() {
    super.resumeAnimation();
    // Timer neu starten, wenn Animation aktiv ist
    if (isActive) {
      _scheduleTimer();
    }
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
            isActive: isActive,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
