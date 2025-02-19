import 'package:flutter/material.dart';
import 'dart:math' as math;

class FaceManipulationPainter extends CustomPainter {
  final double manipulationAmount;

  FaceManipulationPainter(this.manipulationAmount);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFace(canvas, size);
    _drawManipulations(canvas, size);
  }

  void _drawFace(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF262626)
      ..style = PaintingStyle.fill;

    // Base face shape
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.85); // Chin

    // Left side
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.85,
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.25,
      size.height * 0.35,
    );

    // Top area
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.15,
    );

    // Right side
    path.cubicTo(
      size.width * 0.6,
      size.height * 0.15,
      size.width * 0.75,
      size.height * 0.2,
      size.width * 0.75,
      size.height * 0.35,
    );

    path.cubicTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width * 0.7,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.85,
    );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    _drawEyes(canvas, size, paint);
    _drawMouth(canvas, size, paint);
  }

  void _drawEyes(Canvas canvas, Size size, Paint paint) {
    // Left eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      paint,
    );

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      paint,
    );
  }

  void _drawMouth(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.6,
      size.height * 0.65,
    );
    canvas.drawPath(path, paint);
  }

  void _drawManipulations(Canvas canvas, Size size) {
    if (manipulationAmount <= 0) return;

    final manipulationPaint = Paint()
      ..color = Colors.red.withOpacity(0.3 * manipulationAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Highlight manipulated areas with glitch effects
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
