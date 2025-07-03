// Enhanced swipe_tutorial_overlay.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'base_tutorial_overlay.dart';

class SwipeTutorialOverlay extends BaseTutorialOverlay {
  const SwipeTutorialOverlay({
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
      _SwipeTutorialOverlayState();
}

class _SwipeTutorialOverlayState
    extends BaseTutorialOverlayState<SwipeTutorialOverlay> {
  late Animation<double> _navigationButtonPulseAnimation;

  @override
  void setupAnimations() {
    slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // New navigation button pulse animation (same as video tap tutorial)
    _navigationButtonPulseAnimation = Tween<double>(
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

    return Stack(
      children: [
        // Original centered tutorial content
        Center(
          child: Column(
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
          ),
        ),

        // Navigation button pulse animation overlay (positioned over right arrow)
        _buildNavigationButtonPulseOverlay(context),
      ],
    );
  }

  Widget _buildNavigationButtonPulseOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Position over the right navigation button
    // Right navigation button is typically positioned at right: 16px from screen edge
    // So we calculate from the right side: screen width - 16px - button center
    final leftPosition = screenSize.width -
        56 -
        40; // Screen width - button position - half circle

    // Vertical: center of screen
    final topPosition =
        (screenSize.height * 0.5) - 40; // Screen center minus half circle

    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: AnimatedBuilder(
        animation: _navigationButtonPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _navigationButtonPulseAnimation.value,
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
