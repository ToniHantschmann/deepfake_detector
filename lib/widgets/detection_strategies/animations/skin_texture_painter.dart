// lib/widgets/detection_strategies/skin_texture_painter.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SkinTexturePainter extends CustomPainter {
  final double textureAmount;

  SkinTexturePainter(this.textureAmount);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFace(canvas, size);
    _drawSkinTexture(canvas, size);
  }

  void _drawFace(Canvas canvas, Size size) {
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

    // Augen (vereinfacht)
    _drawEyes(canvas, size);

    // Mund (einfache Linie)
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

  void _drawSkinTexture(Canvas canvas, Size size) {
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * textureAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Stirnfalten
    _drawForeheadLines(canvas, size, texturePaint);

    // Wangenlinien
    _drawCheekLines(canvas, size, texturePaint);

    // Natürliche Unregelmäßigkeiten
    if (textureAmount > 0.5) {
      _drawNaturalImperfections(canvas, size, texturePaint);
    }
  }

  void _drawForeheadLines(Canvas canvas, Size size, Paint paint) {
    // Horizontale Stirnfalten
    for (var i = 0; i < 3; i++) {
      final y = size.height * 0.25 + (i * 8);
      final path = Path();
      path.moveTo(size.width * 0.3, y);

      // Wellige Linie für natürlicheres Aussehen
      for (var x = 0.3; x <= 0.7; x += 0.1) {
        path.quadraticBezierTo(
          size.width * (x + 0.05),
          y + math.sin(x * math.pi) * 2,
          size.width * (x + 0.1),
          y,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawCheekLines(Canvas canvas, Size size, Paint paint) {
    // Wangenlinien links
    _drawCheekSide(canvas, size, paint, true);
    // Wangenlinien rechts
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
        y + direction * 10,
        size.width * (startX + direction * 0.15),
        y,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawNaturalImperfections(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fester Seed für konsistente Muster

    // Kleine Punkte und Linien für natürliche Hautstruktur
    for (var i = 0; i < 20; i++) {
      final x = size.width * (0.3 + random.nextDouble() * 0.4);
      final y = size.height * (0.2 + random.nextDouble() * 0.6);

      if (random.nextBool()) {
        // Kleine Linie
        canvas.drawLine(
          Offset(x, y),
          Offset(x + random.nextDouble() * 4, y + random.nextDouble() * 4),
          paint..strokeWidth = 0.5,
        );
      } else {
        // Punkt
        canvas.drawCircle(
          Offset(x, y),
          0.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SkinTexturePainter oldDelegate) {
    return oldDelegate.textureAmount != textureAmount;
  }
}
