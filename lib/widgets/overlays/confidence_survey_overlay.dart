import 'package:deepfake_detector/mixins/game_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_language_extension.dart';
import '../../config/app_config.dart';
import '../../constants/overlay_types.dart';

class ConfidenceSurveyDialog extends StatelessWidget with GameNavigationMixin {
  final VoidCallback onComplete;
  final VoidCallback? onClose;

  const ConfidenceSurveyDialog({
    Key? key,
    required this.onComplete,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).survey;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConfig.colors.overlayBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with close button (only if needed)
            if (onClose != null) _buildHeader(context),

            // Title
            Text(
              strings.confidenceTitle,
              style: AppConfig.textStyles.overlayTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Question
            Text(
              strings.confidenceQuestion,
              style: AppConfig.textStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Rating Scale
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 5; i++) _buildRatingButton(i, context),
              ],
            ),
            const SizedBox(height: 24),

            // Scale Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.confidenceLow,
                  style: AppConfig.textStyles.bodySmall.copyWith(
                    color: AppConfig.colors.textSecondary,
                  ),
                ),
                Text(
                  strings.confidenceHigh,
                  style: AppConfig.textStyles.bodySmall.copyWith(
                    color: AppConfig.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: onClose!,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildRatingButton(int value, BuildContext context) {
    return GestureDetector(
      onTap: () => _handleRatingSelection(value, context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConfig.colors.backgroundLight,
              border: Border.all(
                color: AppConfig.colors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRatingSelection(int rating, BuildContext context) {
    dispatchGameEvent(context, SetInitialConfidenceRating(rating));
    dispatchGameEvent(
        context, const OverlayCompleted(OverlayType.confidenceSurvey));
    dispatchGameEvent(context, const SurveyCompleted());
    onComplete();
  }
}
