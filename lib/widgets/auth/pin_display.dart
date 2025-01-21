import 'package:flutter/material.dart';

class PinDisplay extends StatelessWidget {
  final String pin;
  final int pinLength;
  final Color? activeColor;
  final Color? inactiveColor;

  const PinDisplay({
    Key? key,
    required this.pin,
    this.pinLength = 4,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isActive = index < pin.length;

        return Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? (activeColor ?? Colors.blue)
                  : (inactiveColor ?? Colors.white.withOpacity(0.2)),
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(
                    Icons.circle,
                    size: 12,
                    color: activeColor ?? Colors.blue,
                  )
                : null,
          ),
        );
      }),
    );
  }
}
