// lib/widgets/common/donut_chart.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final bool useThresholdColors;

  const DonutChart({
    Key? key,
    required this.percentage,
    this.size = 100.0,
    this.strokeWidth = 12.0,
    this.backgroundColor = const Color(0xFF404040),
    this.useThresholdColors = false,
  }) : super(key: key);

  // Liefert die Farbe basierend auf Schwellwerten
  Color get progressColor {
    if (!useThresholdColors) {
      // Standard-Farbe wenn keine Schwellwerte verwendet werden
      return Colors.blue;
    }

    // Farbcodierung nach Schwellwerten
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.amber;
    } else if (percentage < 90) {
      return Colors.lightGreen;
    } else {
      return const Color(0xFF00C853); // Ein dunkleres Grün für >90%
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hintergrund-Kreis
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartBackgroundPainter(
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
            ),
          ),

          // Fortschritts-Kreis
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartProgressPainter(
              percentage: percentage,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
            ),
          ),

          // Größere, farblich angepasste Prozentanzeige in der Mitte
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.28, // Größerer Text
                  fontWeight: FontWeight.bold,
                  color: useThresholdColors ? progressColor : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Hintergrund des Donut-Charts
class _DonutChartBackgroundPainter extends CustomPainter {
  final double strokeWidth;
  final Color backgroundColor;

  _DonutChartBackgroundPainter({
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  @override
  bool shouldRepaint(_DonutChartBackgroundPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.backgroundColor != backgroundColor;
}

// Fortschrittsanzeige des Donut-Charts
class _DonutChartProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color progressColor;

  _DonutChartProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Berechne den Winkel basierend auf dem Prozentsatz (0-100% -> 0-360°)
    final sweepAngle = 2 * math.pi * (percentage / 100);

    // Zeichne den Kreisbogen, beginnend oben bei -90° (oder -pi/2 in Radianten)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Startpunkt oben
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutChartProgressPainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.progressColor != progressColor;
}
