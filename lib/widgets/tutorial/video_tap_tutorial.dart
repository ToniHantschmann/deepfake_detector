// Enhanced video_tap_tutorial.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'base_tutorial_overlay.dart';

class VideoTapTutorialOverlay extends BaseTutorialOverlay {
  const VideoTapTutorialOverlay({
    Key? key,
    required VoidCallback onComplete,
    Duration autoHideDuration = const Duration(seconds: 7),
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
  late Animation<double> _playButtonPulseAnimation;

  @override
  void setupAnimations() {
    // Existing center icon pulsing animation
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // New play button pulse animation
    _playButtonPulseAnimation = Tween<double>(
      begin: 2.5, // Start larger
      end: 0.6, // Shrink smaller
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget buildTutorialContent(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).tutorial;
    final screenSize = MediaQuery.of(context).size;
    final isHorizontalLayout = screenSize.width >= 700;

    return Stack(
      children: [
        // Original centered tutorial content
        Center(
          child: Column(
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
          ),
        ),

        // Play button pulse animation overlay
        _buildPlayButtonPulseOverlay(context, isHorizontalLayout),
      ],
    );
  }

  Widget _buildPlayButtonPulseOverlay(
      BuildContext context, bool isHorizontalLayout) {
    final screenSize = MediaQuery.of(context).size;
    final leftPosition = (screenSize.width * 0.275) - 40;
    final topPosition = screenSize.height * 0.4;

    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: AnimatedBuilder(
        animation: _playButtonPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _playButtonPulseAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
