// lib/widgets/detection_strategies/face_painter.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class FacePainter extends CustomPainter {
  final double eyeOpenAmount;

  FacePainter(this.eyeOpenAmount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF262626)
      ..style = PaintingStyle.fill;

    _drawHead(canvas, size, paint, fillPaint);
    _drawEyes(canvas, size, paint, fillPaint);
    _drawMouth(canvas, size, paint);
  }

  void _drawHead(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path();

    // Startpunkt am Kinn
    path.moveTo(size.width * 0.5, size.height * 0.85);

    // Linke Gesichtshälfte
    path.cubicTo(
        size.width * 0.3,
        size.height * 0.85, // Kinnlinie links
        size.width * 0.25,
        size.height * 0.6, // Wangenlinie links
        size.width * 0.25,
        size.height * 0.35 // Schläfe links
        );

    // Oberer Kopfbereich (sanft gerundet)
    path.cubicTo(
        size.width * 0.25,
        size.height * 0.2, // Oberhalb der Schläfe
        size.width * 0.4,
        size.height * 0.15, // Kopfseite links
        size.width * 0.5,
        size.height * 0.15 // Kopfmitte
        );

    // Rechte Gesichtshälfte (gespiegelt)
    path.cubicTo(
        size.width * 0.6,
        size.height * 0.15, // Kopfseite rechts
        size.width * 0.75,
        size.height * 0.2, // Oberhalb der Schläfe
        size.width * 0.75,
        size.height * 0.35 // Schläfe rechts
        );

    path.cubicTo(
        size.width * 0.75,
        size.height * 0.6, // Wangenlinie rechts
        size.width * 0.7,
        size.height * 0.85, // Kinnlinie rechts
        size.width * 0.5,
        size.height * 0.85 // Zurück zum Kinn
        );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  void _drawEyes(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final leftEyeCenter = Offset(size.width * 0.35, size.height * 0.45);
    final rightEyeCenter = Offset(size.width * 0.65, size.height * 0.45);
    final eyeWidth = size.width * 0.12;
    final eyeHeight = size.height * 0.08 * eyeOpenAmount;

    if (eyeOpenAmount > 0.1) {
      // Linkes Auge
      _drawEyeShape(
          canvas, leftEyeCenter, eyeWidth, eyeHeight, paint, fillPaint);
      _drawIrisAndPupil(canvas, leftEyeCenter, size);

      // Rechtes Auge
      _drawEyeShape(
          canvas, rightEyeCenter, eyeWidth, eyeHeight, paint, fillPaint);
      _drawIrisAndPupil(canvas, rightEyeCenter, size);
    }
  }

  void _drawEyeShape(Canvas canvas, Offset center, double width, double height,
      Paint paint, Paint fillPaint) {
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    canvas.drawOval(rect, fillPaint);
    canvas.drawOval(rect, paint);
  }

  void _drawIrisAndPupil(Canvas canvas, Offset center, Size size) {
    // Iris
    final irisPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.03, irisPaint);

    // Pupille
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.015, pupilPaint);

    // Lichtreflex
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(center.dx - size.width * 0.01, center.dy - size.width * 0.01),
        size.width * 0.008,
        highlightPaint);
  }

  void _drawMouth(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.65;

    // Leicht lächelnder Mund
    path.moveTo(centerX - size.width * 0.15, centerY);
    path.quadraticBezierTo(centerX, centerY + size.height * 0.03,
        centerX + size.width * 0.15, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.eyeOpenAmount != eyeOpenAmount;
  }
}
