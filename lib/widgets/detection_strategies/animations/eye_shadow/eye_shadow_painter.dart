import 'package:flutter/material.dart';
import '../common/face_base.dart';
import 'dart:math' as math;

class EyeShadowPainter extends FaceBase {
  final double manipulationAmount;

  EyeShadowPainter({
    required this.manipulationAmount,
    required bool showDetails,
  }) : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: showDetails,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne zuerst das Basis-Gesicht
    drawBaseFace(canvas, size);

    // Füge dann die spezifischen Augenschatten hinzu
    _drawEyeShadows(canvas, size);

    // Zeichne die Augenbrauen
    _drawDetailedEyebrows(canvas, size);
  }

  void _drawEyeShadows(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (manipulationAmount < 0.5) {
      _drawNaturalShadows(canvas, size, shadowPaint);
    } else {
      _drawUnnaturalShadows(canvas, size, shadowPaint);
    }
  }

  void _drawNaturalShadows(Canvas canvas, Size size, Paint paint) {
    // Linkes Auge
    _drawSmoothShadow(
      canvas,
      Offset(size.width * 0.35, size.height * 0.45),
      size.width * 0.12,
      paint,
    );

    // Rechtes Auge
    _drawSmoothShadow(
      canvas,
      Offset(size.width * 0.65, size.height * 0.45),
      size.width * 0.12,
      paint,
    );
  }

  void _drawSmoothShadow(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final shadowPath = Path();
    shadowPath.moveTo(center.dx - radius, center.dy + radius * 0.5);

    shadowPath.quadraticBezierTo(
      center.dx,
      center.dy + radius * 0.8,
      center.dx + radius,
      center.dy + radius * 0.5,
    );

    canvas.drawPath(shadowPath, paint);
  }

  void _drawUnnaturalShadows(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      // Linkes Auge
      canvas.drawLine(
        Offset(size.width * (0.35 - 0.05 * i), size.height * (0.45 + 0.02 * i)),
        Offset(size.width * (0.35 + 0.05 * i), size.height * (0.45 + 0.03 * i)),
        paint,
      );

      // Rechtes Auge
      canvas.drawLine(
        Offset(size.width * (0.65 - 0.05 * i), size.height * (0.45 + 0.02 * i)),
        Offset(size.width * (0.65 + 0.05 * i), size.height * (0.45 + 0.03 * i)),
        paint,
      );
    }
  }

  void _drawDetailedEyebrows(Canvas canvas, Size size) {
    final eyebrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Natürliche oder unnatürliche Augenbrauen basierend auf manipulationAmount
    if (manipulationAmount < 0.5) {
      _drawNaturalEyebrows(canvas, size, eyebrowPaint);
    } else {
      _drawUnnaturalEyebrows(canvas, size, eyebrowPaint);
    }
  }

  void _drawNaturalEyebrows(Canvas canvas, Size size, Paint paint) {
    // Linke Augenbraue
    final leftBrow = Path();
    leftBrow.moveTo(size.width * 0.25, size.height * 0.35);
    leftBrow.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.32,
      size.width * 0.45,
      size.height * 0.35,
    );
    canvas.drawPath(leftBrow, paint);

    // Rechte Augenbraue
    final rightBrow = Path();
    rightBrow.moveTo(size.width * 0.55, size.height * 0.35);
    rightBrow.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.32,
      size.width * 0.75,
      size.height * 0.35,
    );
    canvas.drawPath(rightBrow, paint);
  }

  void _drawUnnaturalEyebrows(Canvas canvas, Size size, Paint paint) {
    // Linke Augenbraue (unnatürlich eckig)
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.35, size.height * 0.32),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.32),
      Offset(size.width * 0.45, size.height * 0.35),
      paint,
    );

    // Rechte Augenbraue (unnatürlich eckig)
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.32),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.32),
      Offset(size.width * 0.75, size.height * 0.35),
      paint,
    );
  }

  @override
  bool shouldRepaint(EyeShadowPainter oldDelegate) {
    return oldDelegate.manipulationAmount != manipulationAmount ||
        oldDelegate.showDetails != showDetails;
  }
}
