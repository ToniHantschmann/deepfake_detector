import 'package:flutter/material.dart';
import 'dart:math' as math;

class FacialFeaturesPainter extends CustomPainter {
  final double featureAmount;

  FacialFeaturesPainter(this.featureAmount);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFace(canvas, size);
    _drawFacialFeatures(canvas, size);
  }

  void _drawFace(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF262626)
      ..style = PaintingStyle.fill;

    // Face shape
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

    // Eyes (simplified)
    _drawEyes(canvas, size);

    // Mouth (simple line)
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.6, size.height * 0.65),
      mouthPaint,
    );
  }

  void _drawEyes(Canvas canvas, Size size) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Left eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      eyePaint,
    );

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      eyePaint,
    );
  }

  void _drawFacialFeatures(Canvas canvas, Size size) {
    final wrinklePaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * featureAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Forehead wrinkles
    _drawForeheadWrinkles(canvas, size, wrinklePaint);

    // Cheek lines and age spots
    _drawCheekFeatures(canvas, size, wrinklePaint);

    // Age-related features
    if (featureAmount > 0.5) {
      _drawAgeSpots(canvas, size, wrinklePaint);
    }
  }

  void _drawForeheadWrinkles(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      final y = size.height * 0.25 + (i * 8);
      final path = Path();
      path.moveTo(size.width * 0.3, y);

      for (var x = 0.3; x <= 0.7; x += 0.1) {
        path.quadraticBezierTo(
          size.width * (x + 0.05),
          y + math.sin(x * math.pi) * 2 * featureAmount,
          size.width * (x + 0.1),
          y,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawCheekFeatures(Canvas canvas, Size size, Paint paint) {
    // Left cheek
    _drawCheekSide(canvas, size, paint, true);
    // Right cheek
    _drawCheekSide(canvas, size, paint, false);
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
        y + direction * 10 * featureAmount,
        size.width * (startX + direction * 0.15),
        y,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawAgeSpots(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);
    final spotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2 * featureAmount)
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
    return oldDelegate.featureAmount != featureAmount;
  }
}
