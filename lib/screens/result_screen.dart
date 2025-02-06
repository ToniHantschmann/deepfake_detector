import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/config.dart';
import 'base_game_screen.dart';

class ResultScreen extends BaseGameScreen {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.isCorrectGuess != current.isCorrectGuess;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    if (state.status == GameStatus.loading ||
        state.selectedVideoIndex == null ||
        state.isCorrectGuess == null ||
        state.videos.isEmpty) {
      return Scaffold(
        backgroundColor: AppConfig.colors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppConfig.colors.primary,
          ),
        ),
      );
    }

    final selectedVideo = state.videos[state.selectedVideoIndex!];

    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: Column(
        children: [
          ProgressBar(currentScreen: state.currentScreen),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.layout.screenPaddingHorizontal,
                      vertical: AppConfig.layout.screenPaddingVertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultHeader(state.isCorrectGuess!),
                        SizedBox(height: AppConfig.layout.spacingXLarge),
                        _buildDeepfakeExplanation(selectedVideo),
                        // Padding für den fixed bottom panel
                        SizedBox(height: AppConfig.layout.spacingXLarge * 6),
                      ],
                    ),
                  ),
                ),
                NavigationButtons.forGameScreen(
                  onNext: () => handleNextNavigation(context),
                  currentScreen: GameScreen.result,
                ),
                _buildStatisticsPanel(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(bool isCorrect) {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
      decoration: BoxDecoration(
        color:
            isCorrect ? AppConfig.colors.success : AppConfig.colors.wrongAnswer,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.error,
            color: AppConfig.colors.textPrimary,
            size: AppConfig.layout.videoControlSize,
          ),
          SizedBox(width: AppConfig.layout.spacingMedium),
          Text(
            isCorrect
                ? AppConfig.strings.result.correctTitle
                : AppConfig.strings.result.wrongTitle,
            style: AppConfig.textStyles.h2,
          ),
        ],
      ),
    );
  }

  Widget _buildDeepfakeExplanation(Video selectedVideo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConfig.strings.result.explanationTitle,
          style: AppConfig.textStyles.h3,
        ),
        SizedBox(height: AppConfig.layout.spacingLarge),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
          decoration: BoxDecoration(
            color: AppConfig.colors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...selectedVideo.deepfakeIndicators.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final indicator = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: AppConfig.layout.spacingMedium,
                  ),
                  child: Text(
                    '${AppConfig.strings.result.reasonPrefix} $index: $indicator',
                    style: AppConfig.textStyles.bodyLarge,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsPanel(GameState state) {
    if (state.userStatistics == null) return const SizedBox.shrink();

    final currentCorrect = state.userStatistics!.recentAttempts
        .where((attempt) => attempt.wasCorrect)
        .length;
    final currentAttempts = state.userStatistics!.recentAttempts.length;
    final totalCorrect = state.userStatistics!.correctGuesses;
    final totalAttempts = state.userStatistics!.totalAttempts;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppConfig.colors.background,
          boxShadow: [
            BoxShadow(
              color: AppConfig.colors.backgroundDark.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
          child: Row(
            children: [
              Expanded(
                child: _buildStatisticsCard(
                  title: AppConfig.strings.result.currentRun,
                  stats:
                      '$currentCorrect ${AppConfig.strings.result.correctFormat} $currentAttempts',
                ),
              ),
              SizedBox(width: AppConfig.layout.spacingLarge),
              Expanded(
                child: _buildStatisticsCard(
                  title: AppConfig.strings.result.overallStats,
                  stats:
                      '$totalCorrect ${AppConfig.strings.result.correctFormat} $totalAttempts',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard({
    required String title,
    required String stats,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppConfig.textStyles.h3,
          ),
          SizedBox(height: AppConfig.layout.spacingSmall),
          Text(
            stats,
            style: AppConfig.textStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}
