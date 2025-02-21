// lib/widgets/detection_strategies/face_moles_painter.dart

import 'package:flutter/material.dart';

class FaceMolesPainter extends CustomPainter {
  final double opacity;

  FaceMolesPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFace(canvas, size);
    _drawMoles(canvas, size);
  }

  void _drawFace(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

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

    canvas.drawPath(path, paint);

    // Augen hinzufügen für mehr Kontext
    _drawEyes(canvas, size, paint);
  }

  void _drawEyes(Canvas canvas, Size size, Paint paint) {
    // Linkes Auge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      paint,
    );

    // Rechtes Auge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.45),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      paint,
    );

    // Einfacher Mund
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.65),
        width: size.width * 0.3,
        height: size.height * 0.1,
      ),
      0,
      3.14,
      false,
      paint,
    );
  }

  void _drawMoles(Canvas canvas, Size size) {
    // Statische Leberflecken (immer sichtbar)
    final staticPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _drawMole(canvas, staticPaint, size.width * 0.35, size.height * 0.4, 3);
    _drawMole(canvas, staticPaint, size.width * 0.65, size.height * 0.45, 2);

    // Dynamische Leberflecken (verschwinden/erscheinen)
    final dynamicPaint = Paint()
      ..color = Colors.white.withOpacity(1 - opacity)
      ..style = PaintingStyle.fill;

    _drawMole(canvas, dynamicPaint, size.width * 0.45, size.height * 0.35, 2.5);
    _drawMole(canvas, dynamicPaint, size.width * 0.55, size.height * 0.5, 3);
    _drawMole(canvas, dynamicPaint, size.width * 0.4, size.height * 0.6, 2);
    _drawMole(canvas, dynamicPaint, size.width * 0.6, size.height * 0.55, 2.5);
  }

  void _drawMole(Canvas canvas, Paint paint, double x, double y, double size) {
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  @override
  bool shouldRepaint(FaceMolesPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
