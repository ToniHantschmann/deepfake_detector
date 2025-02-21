import 'package:flutter/material.dart';
import '../../../../config/config.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton(
          AppConfig.strings.strategyCard.toggleOriginal,
          false,
        ),
        SizedBox(width: AppConfig.layout.spacingMedium),
        _buildModeButton(
          AppConfig.strings.strategyCard.toggleManipulated,
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
