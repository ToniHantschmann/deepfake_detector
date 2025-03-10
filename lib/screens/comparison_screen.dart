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

class ComparisonScreen extends BaseGameScreen {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.selectedVideoIndex != current.selectedVideoIndex ||
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
                        SizedBox(height: AppConfig.layout.spacingXLarge),
                        Expanded(
                          child: _buildVideoComparison(context, state, strings),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConfig.layout.spacingLarge,
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              constraints: BoxConstraints(
                                minWidth: 200,
                                minHeight: AppConfig.layout.buttonHeight,
                                maxHeight: AppConfig.layout.buttonHeight * 1.2,
                              ),
                              child: ElevatedButton(
                                onPressed: state.selectedVideoIndex != null
                                    ? () {
                                        dispatchGameEvent(
                                          context,
                                          SelectDeepfake(
                                              state.selectedVideoIndex!),
                                        );
                                        handleNextNavigation(context);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConfig.colors.primary,
                                  disabledBackgroundColor:
                                      AppConfig.colors.primary.withOpacity(0.3),
                                  disabledForegroundColor: AppConfig
                                      .colors.textPrimary
                                      .withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConfig.layout.buttonHeight / 2),
                                  ),
                                ),
                                child: Text(
                                  strings.confirmButton,
                                  style: AppConfig.textStyles.buttonLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppConfig.layout.spacingMedium),
                      ],
                    ),
                  ),
                  NavigationButtons.forGameScreen(
                    onNext: () {
                      if (state.selectedVideoIndex != null) {
                        dispatchGameEvent(
                            context, SelectDeepfake(state.selectedVideoIndex!));
                        handleNextNavigation(context);
                      }
                    },
                    onBack: () => handleBackNavigation(context),
                    currentScreen: GameScreen.comparison,
                    enableNext: state.selectedVideoIndex != null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoComparison(
      BuildContext context, GameState state, ComparisonScreenStrings strings) {
    return Row(
      children: [
        Expanded(
          child: _buildVideoCard(
              context: context,
              video: state.videos[0],
              isSelected: state.selectedVideoIndex == 0,
              onSelect: () => _handleVideoSelection(context, 0),
              strings: strings),
        ),
        SizedBox(width: AppConfig.layout.spacingLarge),
        Expanded(
          child: _buildVideoCard(
            context: context,
            video: state.videos[1],
            isSelected: state.selectedVideoIndex == 1,
            onSelect: () => _handleVideoSelection(context, 1),
            strings: strings,
          ),
        ),
      ],
    );
  }

  void _handleVideoSelection(BuildContext context, int index) {
    dispatchGameEvent(context, UpdateSelectedVideo(index));
  }

  Widget _buildVideoCard({
    required BuildContext context,
    required Video video,
    required bool isSelected,
    required VoidCallback onSelect,
    required ComparisonScreenStrings strings,
  }) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
            child: Container(
              decoration: BoxDecoration(
                color: AppConfig.colors.backgroundLight,
                borderRadius:
                    BorderRadius.circular(AppConfig.layout.cardRadius),
                border: Border.all(
                  color: isSelected
                      ? AppConfig.colors.primary
                      : Colors.transparent,
                  width: 3, // Dickerer Border
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppConfig.colors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: AppConfig.video.minAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConfig.layout.cardRadius),
                      ),
                      child: Image.asset(
                        video.thumbnailUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppConfig.layout.cardPadding),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: AppConfig.layout.buttonHeight,
                        maxHeight: AppConfig.layout.buttonHeight * 1.2,
                      ),
                      child: ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppConfig.colors.primary
                              : AppConfig.colors.secondary,
                          padding: EdgeInsets.symmetric(
                            vertical: AppConfig.layout.buttonPadding * 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConfig.layout.buttonRadius * 1.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: AppConfig.colors.textPrimary,
                              size: 24,
                            ),
                            SizedBox(width: AppConfig.layout.spacingMedium),
                            Text(
                              strings.selectionButton,
                              style: AppConfig.textStyles.buttonLarge.copyWith(
                                color: AppConfig.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
