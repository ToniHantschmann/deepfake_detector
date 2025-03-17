// Korrigierte Implementierung für video_tap_tutorial_overlay.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'base_tutorial_overlay.dart';

class VideoTapTutorialOverlay extends BaseTutorialOverlay {
  const VideoTapTutorialOverlay({
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
      _VideoTapTutorialOverlayState();
}

class _VideoTapTutorialOverlayState
    extends BaseTutorialOverlayState<VideoTapTutorialOverlay> {
  @override
  void setupAnimations() {
    // Pulsieren statt Schieben für die Tap-Animation
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
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
        ScaleTransition(
          scale: scaleAnimation!,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppConfig.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app,
              color: AppConfig.colors.textPrimary,
              size: 40,
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
            strings.videoTapTooltip,
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
