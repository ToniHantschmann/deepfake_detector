import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/config.dart';

class GeneratedPinDisplay extends StatelessWidget {
  final String pin;
  final Color? accentColor;

  const GeneratedPinDisplay({
    Key? key,
    required this.pin,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppConfig.colors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConfig.layout.overlayPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConfig.layout.overlayRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppConfig.strings.pinDisplay.pinDisplayTitle,
            style: AppConfig.textStyles.overlayTitle,
          ),
          SizedBox(height: AppConfig.layout.spacingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...pin.split('').map((digit) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppConfig.layout.pinDigitSpacing / 2,
                    ),
                    width: AppConfig.layout.pinDigitSize,
                    height: AppConfig.layout.pinDigitSize * 1.2,
                    decoration: BoxDecoration(
                      color: AppConfig.colors.backgroundLight,
                      borderRadius: BorderRadius.circular(
                        AppConfig.layout.pinDigitRadius,
                      ),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        digit,
                        style: AppConfig.textStyles.pinDigit,
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: AppConfig.layout.spacingLarge),
          Text(
            AppConfig.strings.pinDisplay.pinDisplayInstructions,
            style: AppConfig.textStyles.overlaySubtitle,
          ),
          SizedBox(height: AppConfig.layout.spacingMedium),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pin));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppConfig.strings.pinDisplay.pinCopied),
                  duration: AppConfig.timing.pinFeedbackDuration,
                  backgroundColor: AppConfig.colors.success,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: Text(AppConfig.strings.pinDisplay.copyPin),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(
                horizontal: AppConfig.layout.buttonPadding * 1.5,
                vertical: AppConfig.layout.buttonPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
