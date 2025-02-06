import 'package:flutter/material.dart';
import '../../config/config.dart';

class PinDisplay extends StatelessWidget {
  final String pin;

  const PinDisplay({
    Key? key,
    required this.pin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConfig.layout.pinDigitSpacing / 2,
          ),
          child: Container(
            width: AppConfig.layout.pinDigitSize,
            height: AppConfig.layout.pinDigitSize * 1.2,
            decoration: BoxDecoration(
              color: AppConfig.colors.backgroundLight,
              borderRadius:
                  BorderRadius.circular(AppConfig.layout.pinDigitRadius),
              border: Border.all(
                color: AppConfig.colors.pinBorder,
                width: AppConfig.layout.pinDigitBorderWidth,
              ),
            ),
            child: Center(
              child: Text(
                index < pin.length ? pin[index] : '•',
                style: AppConfig.textStyles.pinDigit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
