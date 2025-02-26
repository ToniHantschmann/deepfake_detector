import 'package:flutter/material.dart';
import '../../../../config/app_config.dart';

class AnimationIndicator extends StatelessWidget {
  final bool isManipulated;
  final String normalText;
  final String manipulatedText;

  const AnimationIndicator({
    Key? key,
    required this.isManipulated,
    required this.normalText,
    required this.manipulatedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConfig.animation.normal,
      padding: EdgeInsets.symmetric(
        horizontal: AppConfig.layout.spacingLarge,
        vertical: AppConfig.layout.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: (isManipulated
                ? AppConfig.colors.error
                : AppConfig.colors.secondary)
            .withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: isManipulated
                ? AppConfig.colors.error
                : AppConfig.colors.secondary,
          ),
          SizedBox(width: AppConfig.layout.spacingSmall),
          Text(
            isManipulated ? manipulatedText : normalText,
            style: AppConfig.textStyles.bodySmall.copyWith(
              color: isManipulated
                  ? AppConfig.colors.error
                  : AppConfig.colors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
