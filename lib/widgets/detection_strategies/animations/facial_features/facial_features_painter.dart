// lib/widgets/detection_strategies/animations/facial_features/facial_features_painter.dart

import 'package:flutter/material.dart';
import '../common/face_base.dart';
import 'dart:math' as math;

class FacialFeaturesPainter extends FaceBase {
  final double manipulationAmount;
  final bool showingManipulated;

  FacialFeaturesPainter({
    required this.manipulationAmount,
    required this.showingManipulated,
  }) : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: true,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne das Basis-Gesicht mit den konfigurierten Einstellungen
    drawBaseFace(canvas, size);

    // Füge die altersspezifischen Merkmale hinzu
    _drawAgeFeatures(canvas, size);
  }

  void _drawAgeFeatures(Canvas canvas, Size size) {
    if (!showingManipulated) {
      _drawNaturalFeatures(canvas, size);
    } else {
      _drawInconsistentFeatures(canvas, size);
    }
  }

  void _drawNaturalFeatures(Canvas canvas, Size size) {
    final featurePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Natürliche Stirnfalten
    _drawForeheadWrinkles(canvas, size, featurePaint, natural: true);

    // Natürliche Nasolabialfalten
    _drawNasolabialFolds(canvas, size, featurePaint, natural: true);

    // Natürliche Krähenfüße
    _drawCrowsFeet(canvas, size, featurePaint, natural: true);

    // Natürliche Hautstruktur
    _drawSkinTexture(canvas, size, natural: true);
  }

  void _drawInconsistentFeatures(Canvas canvas, Size size) {
    final featurePaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * manipulationAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Inkonsistente Falten und glatte Bereiche
    _drawForeheadWrinkles(canvas, size, featurePaint, natural: false);
    _drawNasolabialFolds(canvas, size, featurePaint, natural: false);
    _drawCrowsFeet(canvas, size, featurePaint, natural: false);
    _drawSkinTexture(canvas, size, natural: false);
  }

  void _drawForeheadWrinkles(Canvas canvas, Size size, Paint paint,
      {required bool natural}) {
    final startY = size.height * 0.25;

    for (var i = 0; i < 3; i++) {
      final y = startY + (i * size.height * 0.03);
      final path = Path();
      path.moveTo(size.width * 0.35, y);

      if (natural) {
        // Natürliche, fließende Falten
        path.quadraticBezierTo(
          size.width * 0.5,
          y + math.sin(i * math.pi / 2) * 2,
          size.width * 0.65,
          y,
        );
      } else {
        // Unnatürliche, abrupte Falten
        path.lineTo(size.width * 0.5, y + (i % 2 == 0 ? 3 : -3));
        path.lineTo(size.width * 0.65, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawNasolabialFolds(Canvas canvas, Size size, Paint paint,
      {required bool natural}) {
    for (bool isLeft in [true, false]) {
      final startX = size.width * (isLeft ? 0.45 : 0.55);
      final endX = size.width * (isLeft ? 0.4 : 0.6);
      final controlX = size.width * (isLeft ? 0.42 : 0.58);

      final path = Path();
      path.moveTo(startX, size.height * 0.55);

      if (natural) {
        path.quadraticBezierTo(
          controlX,
          size.height * 0.62,
          endX,
          size.height * 0.65,
        );
      } else {
        // Unnatürlich gerade oder abgehackte Linien
        path.lineTo(endX, size.height * 0.65);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawCrowsFeet(Canvas canvas, Size size, Paint paint,
      {required bool natural}) {
    for (bool isLeft in [true, false]) {
      final baseX = size.width * (isLeft ? 0.3 : 0.7);
      final baseY = size.height * 0.45;

      for (var i = 0; i < 3; i++) {
        final startX = baseX;
        final startY = baseY + (i - 1) * 3;

        if (natural) {
          // Natürliche, leicht gebogene Linien
          final path = Path();
          path.moveTo(startX, startY);
          path.quadraticBezierTo(
            startX + (isLeft ? 8 : -8),
            startY + 2,
            startX + (isLeft ? 15 : -15),
            startY + 1,
          );
          canvas.drawPath(path, paint);
        } else {
          // Unnatürlich gerade Linien
          canvas.drawLine(
            Offset(startX, startY),
            Offset(startX + (isLeft ? 15 : -15), startY),
            paint,
          );
        }
      }
    }
  }

  void _drawSkinTexture(Canvas canvas, Size size, {required bool natural}) {
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(natural ? 0.1 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    if (natural) {
      // Feine, gleichmäßige Textur
      for (var i = 0; i < 50; i++) {
        final x = size.width * (0.3 + math.Random().nextDouble() * 0.4);
        final y = size.height * (0.2 + math.Random().nextDouble() * 0.6);
        _drawTexturePoint(canvas, x, y, texturePaint, natural: true);
      }
    } else {
      // Ungleichmäßige Textur mit glatten Bereichen
      for (var i = 0; i < 30; i++) {
        final x = size.width * (0.3 + math.Random().nextDouble() * 0.4);
        final y = size.height * (0.2 + math.Random().nextDouble() * 0.6);
        _drawTexturePoint(canvas, x, y, texturePaint, natural: false);
      }

      // Künstlich glatte Bereiche
      _drawSmoothPatches(canvas, size);
    }
  }

  void _drawTexturePoint(Canvas canvas, double x, double y, Paint paint,
      {required bool natural}) {
    if (natural) {
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    } else {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 1, height: 1),
        paint,
      );
    }
  }

  void _drawSmoothPatches(Canvas canvas, Size size) {
    final smoothPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Verschiedene glatte Bereiche, die mit den Falten kontrastieren
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.35),
        width: size.width * 0.15,
        height: size.height * 0.1,
      ),
      smoothPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.4),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      smoothPaint,
    );
  }

  @override
  bool shouldRepaint(FacialFeaturesPainter oldDelegate) {
    return oldDelegate.manipulationAmount != manipulationAmount ||
        oldDelegate.showingManipulated != showingManipulated;
  }
}
