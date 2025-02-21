import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../common/face_base.dart';

class LipSyncPainter extends FaceBase {
  final double moveAmount;
  final bool isManipulated;

  LipSyncPainter(this.moveAmount, this.isManipulated)
      : super(
          drawEyesOpen: true,
          mouthOpenAmount: moveAmount,
          showDetails: false,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne das Basis-Gesicht
    drawBaseFace(canvas, size);

    // Füge zusätzliche Lippen-Details hinzu
    _drawLipDetails(canvas, size);

    // Füge Desynchronisations-Effekte hinzu wenn manipuliert
    if (isManipulated) {
      _drawDesynchEffects(canvas, size);
    }
  }

  void _drawLipDetails(Canvas canvas, Size size) {
    final lipPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Zeichne die Lippenkontur
    final lipPath = Path();

    // Oberlippe
    lipPath.moveTo(size.width * 0.4, size.height * 0.65);
    lipPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.65 - moveAmount * 0.1),
      size.width * 0.6,
      size.height * 0.65,
    );

    // Unterlippe
    lipPath.moveTo(size.width * 0.4, size.height * 0.65);
    lipPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.65 + moveAmount * 0.1),
      size.width * 0.6,
      size.height * 0.65,
    );

    canvas.drawPath(lipPath, lipPaint);
  }

  void _drawDesynchEffects(Canvas canvas, Size size) {
    final effectPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Verzögerungs-Effekt durch Echo-Linien
    final echoPath = Path();

    // Verzögerte Oberlippe
    final delay = moveAmount * 0.05;
    echoPath.moveTo(size.width * 0.4, size.height * 0.65);
    echoPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.65 - (moveAmount - delay) * 0.1),
      size.width * 0.6,
      size.height * 0.65,
    );

    // Verzögerte Unterlippe
    echoPath.moveTo(size.width * 0.4, size.height * 0.65);
    echoPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.65 + (moveAmount - delay) * 0.1),
      size.width * 0.6,
      size.height * 0.65,
    );

    canvas.drawPath(echoPath, effectPaint);

    // Füge kleine Störungslinien hinzu
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.63 + i * 0.02);
      canvas.drawLine(
        Offset(size.width * 0.4, y),
        Offset(size.width * 0.6, y + math.sin(moveAmount * math.pi) * 2),
        effectPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LipSyncPainter oldDelegate) {
    return oldDelegate.moveAmount != moveAmount ||
        oldDelegate.isManipulated != isManipulated;
  }
}
