import 'package:flutter/material.dart';
import '../common/face_base.dart';
import 'dart:math' as math;

class GlassesPainter extends FaceBase {
  final double reflectionAmount;
  final bool isManipulated;

  GlassesPainter(this.reflectionAmount, this.isManipulated)
      : super(
          drawEyesOpen: true,
          mouthOpenAmount: 0.0,
          showDetails: false,
        );

  @override
  void paint(Canvas canvas, Size size) {
    // Zeichne zuerst das Basis-Gesicht
    drawBaseFace(canvas, size);

    // Zeichne dann die Brille und Reflexionen
    _drawGlasses(canvas, size);
    _drawReflections(canvas, size);
  }

  void _drawGlasses(Canvas canvas, Size size) {
    final glassesPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Linkes Brillenglas
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.45),
        width: size.width * 0.25,
        height: size.height * 0.15,
      ),
      glassesPaint,
    );

    // Rechtes Brillenglas
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.45),
        width: size.width * 0.25,
        height: size.height * 0.15,
      ),
      glassesPaint,
    );

    // Brillensteg
    canvas.drawLine(
      Offset(size.width * 0.475, size.height * 0.45),
      Offset(size.width * 0.525, size.height * 0.45),
      glassesPaint,
    );

    // Brillenbügel
    canvas.drawLine(
      Offset(size.width * 0.225, size.height * 0.45),
      Offset(size.width * 0.15, size.height * 0.4),
      glassesPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.775, size.height * 0.45),
      Offset(size.width * 0.85, size.height * 0.4),
      glassesPaint,
    );
  }

  void _drawReflections(Canvas canvas, Size size) {
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.6 * reflectionAmount)
      ..style = PaintingStyle.fill;

    if (!isManipulated) {
      _drawNaturalReflections(canvas, size, reflectionPaint);
    } else {
      _drawArtificialReflections(canvas, size, reflectionPaint);
    }
  }

  void _drawNaturalReflections(Canvas canvas, Size size, Paint paint) {
    // Konsistente Reflexionen für beide Gläser
    _drawSingleGlassReflection(
      canvas,
      size,
      paint,
      isLeft: true,
      baseX: 0.35,
    );
    _drawSingleGlassReflection(
      canvas,
      size,
      paint,
      isLeft: false,
      baseX: 0.65,
    );
  }

  void _drawSingleGlassReflection(Canvas canvas, Size size, Paint paint,
      {required bool isLeft, required double baseX}) {
    final reflectionPath = Path();
    final startX = size.width * (baseX - 0.05);

    reflectionPath.moveTo(startX, size.height * 0.4);
    reflectionPath.quadraticBezierTo(
      size.width * baseX,
      size.height * 0.425,
      size.width * (baseX + 0.05),
      size.height * 0.4,
    );
    reflectionPath.quadraticBezierTo(
      size.width * baseX,
      size.height * 0.45,
      startX,
      size.height * 0.4,
    );

    canvas.drawPath(reflectionPath, paint);
  }

  void _drawArtificialReflections(Canvas canvas, Size size, Paint paint) {
    // Unnatürliche, inkonsistente Reflexionen
    final random = math.Random(42);

    // Links: vertikale Streifen
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.275 + i * 0.05);
      final deviation = math.sin(reflectionAmount * math.pi * 2) * 5;

      canvas.drawLine(
        Offset(x, size.height * 0.4),
        Offset(x + deviation, size.height * 0.5),
        paint,
      );
    }

    // Rechts: zufällige, inkonsistente Muster
    for (var i = 0; i < 5; i++) {
      final startX = size.width * (0.575 + random.nextDouble() * 0.15);
      final startY = size.height * (0.4 + random.nextDouble() * 0.1);
      final endX = startX + (random.nextDouble() - 0.5) * 20;
      final endY = startY + random.nextDouble() * 20;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GlassesPainter oldDelegate) {
    return oldDelegate.reflectionAmount != reflectionAmount ||
        oldDelegate.isManipulated != isManipulated;
  }
}
