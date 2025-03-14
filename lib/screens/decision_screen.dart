// lib/screens/decision_screen.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';
import 'base_game_screen.dart';

class DecisionScreen extends BaseGameScreen {
  const DecisionScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.userGuessIsDeepfake != current.userGuessIsDeepfake ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(context.currentLocale).comparison;

    if (state.status == GameStatus.loading || state.videos.isEmpty) {
      return Scaffold(
        backgroundColor: AppConfig.colors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            color: AppConfig.colors.primary,
          ),
        ),
      );
    }

    final currentVideo =
        state.videos.first; // Wir zeigen nur das erste Video an

    return Scaffold(
      backgroundColor: AppConfig.colors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            ProgressBar(currentScreen: state.currentScreen),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.layout.screenPaddingHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppConfig.layout.spacingLarge),
                        Text(
                          strings.title,
                          style: AppConfig.textStyles.h2,
                        ),
                        SizedBox(height: AppConfig.layout.spacingSmall),
                        Text(
                          strings.subtitle,
                          style: AppConfig.textStyles.bodyMedium.copyWith(
                            color: AppConfig.colors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: _buildVideoDecision(
                              context, state, currentVideo, strings),
                        ),
                      ],
                    ),
                  ),
                  // Navigation buttons are still included but we don't need them
                  // for our primary interaction flow since buttons now directly navigate
                  NavigationButtons.forGameScreen(
                    onNext: () {
                      if (state.userGuessIsDeepfake != null) {
                        dispatchGameEvent(context,
                            MakeDeepfakeDecision(state.userGuessIsDeepfake!));
                        handleNextNavigation(context);
                      }
                    },
                    onBack: () => handleBackNavigation(context),
                    currentScreen: GameScreen.decision,
                    enableNext: state.userGuessIsDeepfake != null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDecision(BuildContext context, GameState state, Video video,
      DecisionScreenStrings strings) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: AppConfig.layout.spacingMedium),

        // Video thumbnail with constrained height
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.45,
            maxWidth: screenSize.width * 0.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
              child: Image.asset(
                video.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: AppConfig.layout.spacingXLarge),

        // Question label
        Text(
          strings.questionLabel,
          style: AppConfig.textStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppConfig.layout.spacingLarge),

        // Horizontale decision buttons mit direkter Navigation
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 64),
          child: Row(
            children: [
              // Real Video Button (links)
              Expanded(
                child: _buildHorizontalDecisionButton(
                  context: context,
                  label: strings.realButtonLabel,
                  isSelected: state.userGuessIsDeepfake == false,
                  icon: Icons.check_circle,
                  color: AppConfig.colors.success,
                  isDeepfake: false,
                ),
              ),
              SizedBox(width: 128),
              // Deepfake Button (rechts)
              Expanded(
                child: _buildHorizontalDecisionButton(
                  context: context,
                  label: strings.deepfakeButtonLabel,
                  isSelected: state.userGuessIsDeepfake == true,
                  icon: Icons.warning,
                  color: AppConfig.colors.warning,
                  isDeepfake: true,
                ),
              ),
            ],
          ),
        ),

        // Bottom padding for better spacing
        SizedBox(height: AppConfig.layout.spacingLarge * 2),
      ],
    );
  }

  Widget _buildHorizontalDecisionButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color color,
    required bool isDeepfake,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // First set the selection
          dispatchGameEvent(context, UpdateSelectedVideo(isDeepfake));

          // Short delay to show selection before navigating
          Future.delayed(Duration(milliseconds: 200), () {
            // Record decision and navigate
            dispatchGameEvent(context, MakeDeepfakeDecision(isDeepfake));
            handleNextNavigation(context);
          });
        },
        borderRadius: BorderRadius.circular(64),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingLarge,
            horizontal: AppConfig.layout.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : AppConfig.colors.backgroundLight,
            borderRadius: BorderRadius.circular(64),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: isSelected ? 8 : 4,
                spreadRadius: isSelected ? 2 : 0,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppConfig.colors.textSecondary,
                size: 40,
              ),
              SizedBox(height: AppConfig.layout.spacingMedium),
              Text(
                label,
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  color: isSelected ? color : AppConfig.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
