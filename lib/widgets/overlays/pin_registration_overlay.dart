import 'package:flutter/material.dart';

import '../../blocs/game/game_language_extension.dart';
import '../../config/app_config.dart';
import '../../config/localization/string_types.dart';

/// An overlay for PIN registration
class PinRegistrationOverlay extends StatefulWidget {
  final String pin;
  final VoidCallback onClose;
  final VoidCallback onRestart;

  const PinRegistrationOverlay({
    Key? key,
    required this.pin,
    required this.onClose,
    required this.onRestart,
  }) : super(key: key);

  @override
  State<PinRegistrationOverlay> createState() => _PinRegistrationOverlayState();
}

class _PinRegistrationOverlayState extends State<PinRegistrationOverlay> {
  @override
  Widget build(BuildContext context) {
    // Get localized strings for the current locale
    final strings = AppConfig.getStrings(context.currentLocale).auth;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConfig.colors.overlayBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(strings),
            SizedBox(height: AppConfig.layout.spacingXLarge),
            Text(
              strings.pinSavePrompt,
              style: AppConfig.textStyles.overlaySubtitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConfig.layout.spacingLarge),
            _buildPinDisplay(),
            SizedBox(height: AppConfig.layout.spacingLarge),
            _buildStartGameButton(context, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.pinTitle,
          style: AppConfig.textStyles.overlayTitle,
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.pin
          .split('')
          .map((digit) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.layout.pinDigitSpacing / 2,
                ),
                width: AppConfig.layout.pinDigitSize,
                height: AppConfig.layout.pinDigitSize * 1.2,
                decoration: BoxDecoration(
                  color: AppConfig.colors.backgroundLight,
                  borderRadius:
                      BorderRadius.circular(AppConfig.layout.pinDigitRadius),
                  border: Border.all(
                    color: AppConfig.colors.primary.withOpacity(0.3),
                    width: AppConfig.layout.pinDigitBorderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: AppConfig.textStyles.pinDigit,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStartGameButton(BuildContext context, AuthStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onClose();
          widget.onRestart();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.colors.secondary,
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
          ),
        ),
        child: Text(
          strings.startNextGame,
          style: AppConfig.textStyles.buttonLarge,
        ),
      ),
    );
  }
}
