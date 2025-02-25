import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../widgets/auth/auth_overlay_base.dart';
import '../config/app_config.dart';

class PinOverlay extends StatelessWidget {
  final String pin;
  final VoidCallback onClose;

  const PinOverlay({
    Key? key,
    required this.pin,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).auth;
    return AuthOverlayBase(
      title: strings.pinTitle,
      onClose: onClose,
      children: [
        Text(
          strings.pinSubtitle,
          style: AppConfig.textStyles.overlaySubtitle,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppConfig.layout.spacingXLarge),
        Text(
          strings.pinSavePrompt,
          style: AppConfig.textStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppConfig.layout.spacingLarge),
        _buildPinDisplay(),
        SizedBox(height: AppConfig.layout.spacingLarge),
        _buildCopyButton(context, strings),
        SizedBox(height: AppConfig.layout.spacingXLarge),
        _buildStartGameButton(context, strings),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pin
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

  Widget _buildCopyButton(BuildContext context, AuthStrings strings) {
    return ElevatedButton.icon(
      onPressed: () => _copyPinToClipboard(context, strings),
      icon: Icon(
        Icons.copy,
        color: AppConfig.colors.textPrimary,
      ),
      label: Text(
        strings.copyPin,
        style: AppConfig.textStyles.buttonMedium,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.colors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.spacingLarge,
          vertical: AppConfig.layout.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
        ),
      ),
    );
  }

  Widget _buildStartGameButton(BuildContext context, AuthStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onClose();
          context.read<GameBloc>().add(const RestartGame());
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

  void _copyPinToClipboard(BuildContext context, AuthStrings strings) {
    Clipboard.setData(ClipboardData(text: pin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.pinCopied),
        duration: AppConfig.timing.tooltipDuration,
        backgroundColor: AppConfig.colors.success,
      ),
    );
  }
}
