import 'package:flutter/material.dart';

class EyePainter extends CustomPainter {
  final double openAmount;

  EyePainter(this.openAmount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final h = size.height * openAmount;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width,
        height: h,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(EyePainter oldDelegate) {
    return oldDelegate.openAmount != openAmount;
  }
}
