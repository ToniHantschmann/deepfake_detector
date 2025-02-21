// lib/widgets/detection_strategies/animations/research/research_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/face_base.dart';

class ResearchPainter extends FaceBase {
  final double progress;
  final int currentStep;
  final bool isActive;

  ResearchPainter({
    required this.progress,
    required this.currentStep,
    required this.isActive,
  }) : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: false,
        );

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawResearchSteps(canvas, size);
    if (isActive) {
      _drawProgressAnimation(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF262626)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawResearchSteps(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    final steps = [
      _StepConfig('🔍', Colors.blue),
      _StepConfig('✓', Colors.green),
      _StepConfig('📊', Colors.purple),
    ];

    for (var i = 0; i < steps.length; i++) {
      final angle = (2 * math.pi * i) / 3;
      final stepCenter = _getStepPosition(center, radius, angle);
      _drawStep(canvas, stepCenter, radius * 0.25, steps[i], i == currentStep);

      // Verbindungslinien zeichnen
      if (i < steps.length - 1) {
        final nextAngle = (2 * math.pi * (i + 1)) / 3;
        final nextCenter = _getStepPosition(center, radius, nextAngle);
        _drawConnection(canvas, stepCenter, nextCenter);
      }
    }
  }

  void _drawStep(Canvas canvas, Offset center, double radius, _StepConfig step,
      bool isCurrentStep) {
    // Hintergrundkreis
    final bgPaint = Paint()
      ..color = step.color.withOpacity(isCurrentStep && isActive ? 0.3 : 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Rand
    final borderPaint = Paint()
      ..color = step.color.withOpacity(isCurrentStep && isActive ? 1.0 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Icon
    _drawIcon(canvas, center, radius, step.icon);
  }

  void _drawIcon(Canvas canvas, Offset center, double radius, String icon) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: TextStyle(
          fontSize: radius,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(start, end, paint);
  }

  void _drawProgressAnimation(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    final currentAngle = (2 * math.pi * currentStep) / 3;
    final nextAngle = (2 * math.pi * ((currentStep + 1) % 3)) / 3;

    final start = _getStepPosition(center, radius, currentAngle);
    final end = _getStepPosition(center, radius, nextAngle);

    // Progress-Linie
    final progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final currentPoint = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    canvas.drawLine(start, currentPoint, progressPaint);

    // Bewegender Punkt
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPoint, 5.0, dotPaint);
  }

  Offset _getStepPosition(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(ResearchPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentStep != currentStep ||
        oldDelegate.isActive != isActive;
  }
}

class _StepConfig {
  final String icon;
  final Color color;

  _StepConfig(this.icon, this.color);
}
