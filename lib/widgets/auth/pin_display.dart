import 'package:flutter/material.dart';

class PinDisplay extends StatelessWidget {
  final String pin;
  final int pinLength;

  const PinDisplay({
    Key? key,
    required this.pin,
    this.pinLength = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        return Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: index < pin.length
                  ? Colors.blue
                  : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: index < pin.length
                ? const Icon(Icons.circle, size: 12, color: Colors.blue)
                : null,
          ),
        );
      }),
    );
  }
}
