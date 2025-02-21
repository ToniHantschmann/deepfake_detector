import 'package:flutter/material.dart';
import '../common/face_base.dart';
import 'dart:math' as math;

class FacialFeaturesPainter extends FaceBase {
  final double manipulationAmount;

  FacialFeaturesPainter(this.manipulationAmount)
      : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: true,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne das Basis-Gesicht
    drawBaseFace(canvas, size);

    // Füge die altersspezifischen Merkmale hinzu
    if (manipulationAmount > 0) {
      _drawAgeFeatures(canvas, size);
    }
  }

  void _drawAgeFeatures(Canvas canvas, Size size) {
    final featurePaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * manipulationAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawForeheadWrinkles(canvas, size, featurePaint);
    _drawCheekFeatures(canvas, size, featurePaint);

    if (manipulationAmount > 0.5) {
      _drawAgeSpots(canvas, size, featurePaint);
    }
  }

  void _drawForeheadWrinkles(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      final y = size.height * 0.25 + (i * 8);
      final path = Path();
      path.moveTo(size.width * 0.3, y);

      // Erstelle wellige Linien für die Stirnfalten
      for (var x = 0.3; x <= 0.7; x += 0.1) {
        path.quadraticBezierTo(
          size.width * (x + 0.05),
          y + math.sin(x * math.pi) * 2 * manipulationAmount,
          size.width * (x + 0.1),
          y,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawCheekFeatures(Canvas canvas, Size size, Paint paint) {
    _drawCheekSide(canvas, size, paint, true); // Links
    _drawCheekSide(canvas, size, paint, false); // Rechts
  }

  void _drawCheekSide(Canvas canvas, Size size, Paint paint, bool isLeft) {
    final startX = isLeft ? 0.25 : 0.75;
    final controlX = isLeft ? 0.35 : 0.65;
    final direction = isLeft ? 1 : -1;

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * (0.5 + i * 0.05);

      path.moveTo(size.width * startX, y);
      path.quadraticBezierTo(
        size.width * controlX,
        y + direction * 10 * manipulationAmount,
        size.width * (startX + direction * 0.15),
        y,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawAgeSpots(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);
    final spotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2 * manipulationAmount)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 15; i++) {
      final x = size.width * (0.3 + random.nextDouble() * 0.4);
      final y = size.height * (0.2 + random.nextDouble() * 0.6);
      final spotSize = 1.5 + random.nextDouble() * 2;

      canvas.drawCircle(
        Offset(x, y),
        spotSize,
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FacialFeaturesPainter oldDelegate) {
    return oldDelegate.manipulationAmount != manipulationAmount;
  }
}
