import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../../../config/app_config.dart';

class AnimationControls extends StatelessWidget {
  final bool isManipulated;
  final ValueChanged<bool> onModeChanged;

  const AnimationControls({
    Key? key,
    required this.isManipulated,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).strategyCard;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton(
          strings.toggleOriginal,
          false,
        ),
        SizedBox(width: AppConfig.layout.spacingMedium),
        _buildModeButton(
          strings.toggleManipulated,
          true,
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, bool manipulated) {
    final isSelected = isManipulated == manipulated;
    return TextButton(
      onPressed: () => onModeChanged(manipulated),
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? AppConfig.colors.primary : AppConfig.colors.background,
        padding: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.spacingLarge,
          vertical: AppConfig.layout.spacingMedium,
        ),
      ),
      child: Text(
        label,
        style: AppConfig.textStyles.buttonMedium.copyWith(
          color: isSelected
              ? AppConfig.colors.textPrimary
              : AppConfig.colors.textSecondary,
        ),
      ),
    );
  }
}
