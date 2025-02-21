import 'package:flutter/material.dart';
import '../common/face_base.dart';

class BlinkingPainter extends FaceBase {
  final double eyeOpenAmount;

  BlinkingPainter(this.eyeOpenAmount)
      : super(
          drawEyesOpen: eyeOpenAmount > 0.1,
          mouthOpenAmount: 0.0,
          showDetails: false,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne das Basis-Gesicht mit den konfigurierten Einstellungen
    drawBaseFace(canvas, size);

    // Zeichne die Iris und Pupillen nur wenn die Augen offen sind
    if (drawEyesOpen) {
      _drawIrisAndPupils(canvas, size);
    }
  }

  void _drawIrisAndPupils(Canvas canvas, Size size) {
    // Linkes Auge
    _drawEyeDetails(
        canvas, Offset(size.width * 0.35, size.height * 0.45), size);

    // Rechtes Auge
    _drawEyeDetails(
        canvas, Offset(size.width * 0.65, size.height * 0.45), size);
  }

  void _drawEyeDetails(Canvas canvas, Offset center, Size size) {
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

    // Lichtreflektion
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.01, center.dy - size.width * 0.01),
      size.width * 0.008,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(BlinkingPainter oldDelegate) {
    return oldDelegate.eyeOpenAmount != eyeOpenAmount;
  }
}
