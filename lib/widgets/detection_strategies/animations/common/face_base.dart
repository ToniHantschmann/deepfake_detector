// lib/widgets/detection_strategies/animations/common/face_base.dart

import 'package:flutter/material.dart';

abstract class FaceBase extends CustomPainter {
  // Optionen für die Gesichtsdarstellung
  bool drawEyesOpen; // Augen offen/geschlossen für Blinzel-Animation
  double mouthOpenAmount; // Mund-Öffnungsgrad für Lip-Sync
  bool showDetails; // Details wie Falten für Facial Features

  FaceBase({
    this.drawEyesOpen = true,
    this.mouthOpenAmount = 0.0,
    this.showDetails = false,
  });

  void drawBaseFace(Canvas canvas, Size size) {
    _drawHead(canvas, size);

    if (drawEyesOpen) {
      _drawOpenEyes(canvas, size);
    } else {
      _drawClosedEyes(canvas, size);
    }

    _drawMouth(canvas, size);

    if (showDetails) {
      _drawFacialDetails(canvas, size);
    }
  }

  void _drawHead(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF262626)
      ..style = PaintingStyle.fill;

    // Gesichtsform
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.85); // Kinn

    // Linke Seite
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.85,
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.25,
      size.height * 0.35,
    );

    // Oberer Bereich
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.15,
    );

    // Rechte Seite
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
  }

  void _drawOpenEyes(Canvas canvas, Size size) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Linkes Auge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      eyePaint,
    );

    // Rechtes Auge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      eyePaint,
    );
  }

  void _drawClosedEyes(Canvas canvas, Size size) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Linkes geschlossenes Auge
    canvas.drawLine(
      Offset(size.width * 0.29, size.height * 0.45),
      Offset(size.width * 0.41, size.height * 0.45),
      eyePaint,
    );

    // Rechtes geschlossenes Auge
    canvas.drawLine(
      Offset(size.width * 0.59, size.height * 0.45),
      Offset(size.width * 0.71, size.height * 0.45),
      eyePaint,
    );
  }

  void _drawMouth(Canvas canvas, Size size) {
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.65);

    if (mouthOpenAmount > 0) {
      // Geöffneter Mund für Lip-Sync
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.65 + mouthOpenAmount * 0.1),
        size.width * 0.6,
        size.height * 0.65,
      );
    } else {
      // Geschlossener Mund
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.65,
        size.width * 0.6,
        size.height * 0.65,
      );
    }

    canvas.drawPath(path, mouthPaint);
  }

  void _drawFacialDetails(Canvas canvas, Size size) {
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Stirnfalten
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.25),
      Offset(size.width * 0.65, size.height * 0.25),
      detailPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.28),
      Offset(size.width * 0.65, size.height * 0.28),
      detailPaint,
    );

    // Nasolabialfalten (Falten von der Nase zum Mundwinkel)
    _drawCurvedLine(
      canvas,
      size,
      Offset(size.width * 0.45, size.height * 0.55),
      Offset(size.width * 0.4, size.height * 0.65),
      detailPaint,
    );

    _drawCurvedLine(
      canvas,
      size,
      Offset(size.width * 0.55, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.65),
      detailPaint,
    );
  }

  void _drawCurvedLine(
    Canvas canvas,
    Size size,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final controlPoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }
}
