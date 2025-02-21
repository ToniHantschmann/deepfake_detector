import 'package:flutter/material.dart';
import '../common/face_base.dart';
import 'dart:math' as math;

class FacialHairPainter extends FaceBase {
  final double manipulationAmount;

  FacialHairPainter(this.manipulationAmount)
      : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: true,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the base face first using the parent class
    drawBaseFace(canvas, size);

    // Draw beard with manipulation amount
    _drawBeard(canvas, size);
  }

  void _drawBeard(Canvas canvas, Size size) {
    final beardPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw base beard shape
    final beardPath = Path();
    beardPath.moveTo(size.width * 0.3, size.height * 0.6);

    // Left side of beard
    beardPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.85,
    );

    // Right side of beard
    beardPath.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.75,
      size.width * 0.7,
      size.height * 0.6,
    );

    canvas.drawPath(beardPath, beardPaint);

    // Add beard details based on manipulation amount
    final random = math.Random(42);

    if (manipulationAmount < 0.5) {
      // Natural beard texture - flowing strands
      for (var i = 0; i < 60; i++) {
        final x = size.width * (0.3 + random.nextDouble() * 0.4);
        final y = size.height * (0.6 + random.nextDouble() * 0.25);
        final length = 2.0 + random.nextDouble() * 4.0;
        final angle = random.nextDouble() * math.pi / 2 - math.pi / 4;

        canvas.drawLine(
          Offset(x, y),
          Offset(
            x + math.cos(angle) * length,
            y + math.sin(angle) * length,
          ),
          beardPaint..strokeWidth = 0.8,
        );
      }
    } else {
      // Artificial/glitchy beard texture
      for (var i = 0; i < 30; i++) {
        final x = size.width * (0.3 + random.nextDouble() * 0.4);
        final y = size.height * (0.6 + random.nextDouble() * 0.25);

        // Draw pixelated/glitchy squares
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 3 + random.nextDouble() * 3,
            height: 3 + random.nextDouble() * 3,
          ),
          beardPaint..strokeWidth = 1,
        );

        // Add some glitch lines
        if (i % 5 == 0) {
          final glitchLength = 10.0 + random.nextDouble() * 15.0;
          canvas.drawLine(
            Offset(x - glitchLength / 2, y),
            Offset(x + glitchLength / 2, y),
            beardPaint..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(FacialHairPainter oldDelegate) {
    return oldDelegate.manipulationAmount != manipulationAmount;
  }
}
