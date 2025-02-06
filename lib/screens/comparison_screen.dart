import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/config.dart';
import 'base_game_screen.dart';

class ComparisonScreen extends BaseGameScreen {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.selectedVideoIndex != current.selectedVideoIndex;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
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
                          AppConfig.strings.comparison.title,
                          style: AppConfig.textStyles.h2,
                        ),
                        SizedBox(height: AppConfig.layout.spacingSmall),
                        Text(
                          AppConfig.strings.comparison.subtitle,
                          style: AppConfig.textStyles.bodyMedium.copyWith(
                            color: AppConfig.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppConfig.layout.spacingXLarge),
                        Expanded(
                          child: _buildVideoComparison(context, state),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConfig.layout.spacingLarge,
                            horizontal: AppConfig.layout.spacingXLarge,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: AppConfig.layout.buttonHeight,
                            child: state.selectedVideoIndex != null
                                ? ElevatedButton(
                                    onPressed: () {
                                      dispatchGameEvent(
                                        context,
                                        SelectDeepfake(
                                            state.selectedVideoIndex!),
                                      );
                                      handleNextNavigation(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConfig.colors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppConfig.layout.buttonRadius),
                                      ),
                                    ),
                                    child: Text(
                                      AppConfig
                                          .strings.comparison.confirmButton,
                                      style: AppConfig.textStyles.buttonLarge,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NavigationButtons.forGameScreen(
                    onNext: () {
                      dispatchGameEvent(
                          context, SelectDeepfake(state.selectedVideoIndex!));
                      handleNextNavigation(context);
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

  Widget _buildVideoComparison(BuildContext context, GameState state) {
    return Row(
      children: [
        Expanded(
          child: _buildVideoCard(
            context: context,
            video: state.videos[0],
            isSelected: state.selectedVideoIndex == 0,
            onSelect: () => _handleVideoSelection(context, 0),
          ),
        ),
        SizedBox(width: AppConfig.layout.spacingLarge),
        Expanded(
          child: _buildVideoCard(
            context: context,
            video: state.videos[1],
            isSelected: state.selectedVideoIndex == 1,
            onSelect: () => _handleVideoSelection(context, 1),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        border: Border.all(
          color: isSelected ? AppConfig.colors.primary : Colors.transparent,
          width: 2,
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: AppConfig.textStyles.h3,
                ),
                SizedBox(height: AppConfig.layout.spacingSmall),
                Text(
                  video.description,
                  style: AppConfig.textStyles.bodyMedium.copyWith(
                    color: AppConfig.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppConfig.layout.spacingLarge),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppConfig.colors.primary
                          : AppConfig.colors.backgroundLight,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConfig.layout.buttonPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConfig.layout.buttonRadius),
                      ),
                    ),
                    child: Text(
                      AppConfig.strings.comparison.selectionButton,
                      style: AppConfig.textStyles.buttonMedium.copyWith(
                        color: isSelected
                            ? AppConfig.colors.textPrimary
                            : AppConfig.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
