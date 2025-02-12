import 'package:flutter/material.dart';

class LipPainter extends CustomPainter {
  final double moveAmount;

  LipPainter(this.moveAmount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;

    final openAmount = moveAmount * height * 0.3;

    path.moveTo(0, height / 2);
    path.quadraticBezierTo(
      width / 2,
      height / 2 - openAmount,
      width,
      height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LipPainter oldDelegate) {
    return oldDelegate.moveAmount != moveAmount;
  }
}
