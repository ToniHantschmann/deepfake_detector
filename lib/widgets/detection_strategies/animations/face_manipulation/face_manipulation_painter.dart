import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/face_base.dart';

class FaceManipulationPainter extends FaceBase {
  final double manipulationAmount;

  FaceManipulationPainter(this.manipulationAmount)
      : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: true,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne zuerst das Basis-Gesicht
    drawBaseFace(canvas, size);

    // Füge dann die Manipulationseffekte hinzu
    if (manipulationAmount > 0) {
      _drawManipulations(canvas, size);
    }
  }

  void _drawManipulations(Canvas canvas, Size size) {
    final manipulationPaint = Paint()
      ..color = Colors.red.withOpacity(0.3 * manipulationAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _drawGlitchEffects(canvas, size, manipulationPaint);
    _drawDistortionLines(canvas, size, manipulationPaint);
    _drawArtifacts(canvas, size, manipulationPaint);
  }

  void _drawGlitchEffects(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);
    final glitchPath = Path();

    for (var i = 0; i < 5; i++) {
      final startX = size.width * (0.3 + random.nextDouble() * 0.4);
      final startY = size.height * (0.2 + random.nextDouble() * 0.6);
      final endX =
          startX + (random.nextDouble() - 0.5) * 30 * manipulationAmount;
      final endY =
          startY + (random.nextDouble() - 0.5) * 30 * manipulationAmount;

      glitchPath.moveTo(startX, startY);
      glitchPath.lineTo(endX, endY);
    }

    canvas.drawPath(glitchPath, paint);
  }

  void _drawDistortionLines(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.3 + i * 0.2);
      final path = Path();
      path.moveTo(size.width * 0.3, y);

      for (var x = 0.0; x <= 1.0; x += 0.1) {
        path.lineTo(
          size.width * (0.3 + x * 0.4),
          y + math.sin(x * math.pi * 2) * 5 * manipulationAmount,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawArtifacts(Canvas canvas, Size size, Paint paint) {
    final artifactPaint = Paint()
      ..color = Colors.red.withOpacity(0.2 * manipulationAmount)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final random = math.Random(i);
      final x = size.width * (0.3 + random.nextDouble() * 0.4);
      final y = size.height * (0.2 + random.nextDouble() * 0.6);
      final radius = 3.0 * manipulationAmount;

      canvas.drawCircle(Offset(x, y), radius, artifactPaint);
    }
  }

  @override
  bool shouldRepaint(FaceManipulationPainter oldDelegate) {
    return oldDelegate.manipulationAmount != manipulationAmount;
  }
}
