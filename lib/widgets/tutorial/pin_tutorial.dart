// lib/widgets/tutorial/pin_tutorial.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'base_tutorial_overlay.dart';

class PinTutorialOverlay extends BaseTutorialOverlay {
  const PinTutorialOverlay({
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
      _PinTutorialOverlayState();
}

class _PinTutorialOverlayState
    extends BaseTutorialOverlayState<PinTutorialOverlay> {
  late Animation<double> _saveButtonPulseAnimation;

  @override
  void setupAnimations() {
    // Pulsierende Animation für den Pin-Button
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    // Save button pulse animation
    _saveButtonPulseAnimation = Tween<double>(
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
                    color: AppConfig.colors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pin_outlined,
                    color: AppConfig.colors.textPrimary,
                    size: 36,
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
                  strings.pinGenerateTutorial,
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

        // Save button pulse animation overlay
        _buildSaveButtonPulseOverlay(context),
      ],
    );
  }

  Widget _buildSaveButtonPulseOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Position over the save game button (rightmost button in statistics screen)
    // Assume the button is positioned at the right side with some margin
    final leftPosition =
        screenSize.width * 0.75; // Approximate position of save button
    final topPosition =
        screenSize.height * 0.85; // Near bottom where buttons are

    return Positioned(
      left: leftPosition,
      top: topPosition,
      child: AnimatedBuilder(
        animation: _saveButtonPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _saveButtonPulseAnimation.value,
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
