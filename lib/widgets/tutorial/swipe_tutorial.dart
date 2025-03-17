// lib/widgets/tutorial/swipe_tutorial_overlay.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'base_tutorial_overlay.dart';

class SwipeTutorialOverlay extends BaseTutorialOverlay {
  const SwipeTutorialOverlay({
    Key? key,
    required VoidCallback onComplete,
    Duration autoHideDuration = const Duration(seconds: 5),
  }) : super(
          key: key,
          onComplete: onComplete,
          autoHideDuration: autoHideDuration,
        );

  @override
  BaseTutorialOverlayState<BaseTutorialOverlay> createState() =>
      _SwipeTutorialOverlayState();
}

class _SwipeTutorialOverlayState
    extends BaseTutorialOverlayState<SwipeTutorialOverlay> {
  @override
  void setupAnimations() {
    slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget buildTutorialContent(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).tutorial;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SlideTransition(
          position: slideAnimation!,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConfig.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swipe,
              color: AppConfig.colors.textPrimary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppConfig.colors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            strings.swipeTooltip,
            style: AppConfig.textStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.touchToContinue,
          style: AppConfig.textStyles.bodySmall.copyWith(
            color: AppConfig.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
