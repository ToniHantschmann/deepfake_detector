import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_language_extension.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';
import '../config/localization/string_types.dart';
import 'base_game_screen.dart';
import '../widgets/common/video_player_overlay.dart';

class ResultScreen extends BaseGameScreen {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.isCorrectGuess != current.isCorrectGuess ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(context.currentLocale).result;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    // Verschiedene Höhenkomponenten
    final progressBarHeight = 56.0; // Höhe der ProgressBar
    final statisticsPanelHeight =
        screenSize.height * 0.22; // Statistik-Panel-Höhe (leicht erhöht)
    final headerHeight = 80.0; // Geschätzte Höhe des Headers
    final titleHeight = 56.0; // Höhe des "Video-Vergleich" Titels

    // Verfügbare Höhe für die Videokarten
    final availableHeight = screenSize.height -
        progressBarHeight -
        statisticsPanelHeight -
        headerHeight -
        titleHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        40.0; // Extra Puffer

    // Bestimme basierend auf der Bildschirmbreite, ob wir horizontal oder vertikal layouten
    final isHorizontalLayout = screenSize.width >= 700;

    if (state.status == GameStatus.loading ||
        state.userGuessIsDeepfake == null ||
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

    // Das erste Video ist das angezeigte Video, das zweite ist das Gegenstück
    final shownVideo = state.videos.first;
    final counterpartVideo = state.videos.length > 1 ? state.videos[1] : null;

    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: Column(
        children: [
          ProgressBar(currentScreen: state.currentScreen),
          Expanded(
            child: Stack(
              children: [
                // Hauptinhalt ohne Scrollview
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConfig.layout.screenPaddingHorizontal,
                    vertical: AppConfig.layout.screenPaddingVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ergebnis-Header
                      _buildResultHeader(state.isCorrectGuess!, strings),
                      SizedBox(height: 16.0),

                      // Video-Vergleich-Titel
                      if (counterpartVideo != null)
                        Text(
                          "Video-Vergleich",
                          style: AppConfig.textStyles.h3,
                        ),

                      SizedBox(height: 8.0),

                      // Video-Vergleich in einem Container mit fester Höhe
                      if (counterpartVideo != null)
                        Container(
                          height: availableHeight,
                          child: isHorizontalLayout
                              ? _buildHorizontalVideoComparison(
                                  shownVideo,
                                  counterpartVideo,
                                  state.isCorrectGuess!,
                                  state.userGuessIsDeepfake!,
                                  context)
                              : _buildVerticalVideoComparison(
                                  shownVideo,
                                  counterpartVideo,
                                  state.isCorrectGuess!,
                                  state.userGuessIsDeepfake!,
                                  context),
                        ),

                      // Platzhalter für den unteren Bereich, um Überlappung mit Statistiken zu vermeiden
                      Spacer(),
                    ],
                  ),
                ),

                // Navigation Buttons
                NavigationButtons.forGameScreen(
                  onNext: () => handleNextNavigation(context),
                  currentScreen: state.currentScreen,
                ),

                // Statistik-Panel am unteren Bildschirmrand
                _buildStatisticsPanel(state, strings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Horizontales Layout für die Videokarten
  Widget _buildHorizontalVideoComparison(
    Video shownVideo,
    Video counterpartVideo,
    bool isCorrect,
    bool userGuessIsDeepfake,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildVideoCard(
            video: shownVideo,
            isDeepfake: shownVideo.isDeepfake,
            title: "Gezeigtes Video",
            context: context,
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildVideoCard(
            video: counterpartVideo,
            isDeepfake: counterpartVideo.isDeepfake,
            title: "Vergleichsvideo",
            context: context,
          ),
        ),
      ],
    );
  }

  // Vertikales Layout für die Videokarten
  Widget _buildVerticalVideoComparison(
    Video shownVideo,
    Video counterpartVideo,
    bool isCorrect,
    bool userGuessIsDeepfake,
    BuildContext context,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildVideoCard(
            video: shownVideo,
            isDeepfake: shownVideo.isDeepfake,
            title: "Gezeigtes Video",
            context: context,
          ),
        ),
        SizedBox(height: 12.0),
        Expanded(
          child: _buildVideoCard(
            video: counterpartVideo,
            isDeepfake: counterpartVideo.isDeepfake,
            title: "Vergleichsvideo",
            context: context,
          ),
        ),
      ],
    );
  }

  // Video-Overlay anzeigen
  void _showVideoOverlay(BuildContext context, Video video) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: VideoPlayerContent(
            video: video,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  // Ergebnis-Header
  Widget _buildResultHeader(bool isCorrect, ResultScreenStrings strings) {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.spacingMedium),
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
            size: 36,
          ),
          SizedBox(width: AppConfig.layout.spacingMedium),
          Expanded(
            child: Text(
              isCorrect ? strings.correctTitle : strings.wrongTitle,
              style: AppConfig.textStyles.h3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Kompakte Videokarte mit flexibler Höhe
  Widget _buildVideoCard({
    required Video video,
    required bool isDeepfake,
    required String title,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        border: Border.all(
          color:
              isDeepfake ? AppConfig.colors.warning : AppConfig.colors.success,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Titel
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppConfig.textStyles.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Thumbnail mit Expanded für flexible Höhe
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.zero,
                    bottom: Radius.circular(AppConfig.layout.cardRadius - 2),
                  ),
                  child: Image.asset(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // Status-Indikator oben rechts
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDeepfake
                          ? AppConfig.colors.warning
                          : AppConfig.colors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDeepfake ? Icons.warning : Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isDeepfake ? "Deepfake" : "Echt",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Play-Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () => _showVideoOverlay(context, video),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppConfig.colors.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
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

  // Statistik-Panel am unteren Bildschirmrand
  Widget _buildStatisticsPanel(GameState state, ResultScreenStrings strings) {
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
      child: Material(
        color: AppConfig.colors.background,
        elevation: 12,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 500;

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.layout.spacingLarge,
                  vertical: AppConfig.layout.spacingLarge,
                ),
                child: isVeryNarrow
                    ? _buildVerticalLayout(strings, currentCorrect,
                        currentAttempts, totalCorrect, totalAttempts)
                    : _buildHorizontalLayout(strings, currentCorrect,
                        currentAttempts, totalCorrect, totalAttempts),
              );
            },
          ),
        ),
      ),
    );
  }

  // Vertikales Layout für die Statistiken
  Widget _buildVerticalLayout(ResultScreenStrings strings, int currentCorrect,
      int currentAttempts, int totalCorrect, int totalAttempts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatisticsCard(
          icon: Icons.straighten,
          title: strings.currentRun,
          correct: currentCorrect,
          total: currentAttempts,
          isVertical: true,
        ),
        SizedBox(height: AppConfig.layout.spacingMedium),
        Divider(height: 2, thickness: 1, color: AppConfig.colors.border),
        SizedBox(height: AppConfig.layout.spacingMedium),
        _buildStatisticsCard(
          icon: Icons.history,
          title: strings.overallStats,
          correct: totalCorrect,
          total: totalAttempts,
          isVertical: true,
        ),
      ],
    );
  }

  // Horizontales Layout für die Statistiken
  Widget _buildHorizontalLayout(ResultScreenStrings strings, int currentCorrect,
      int currentAttempts, int totalCorrect, int totalAttempts) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildStatisticsCard(
            icon: Icons.straighten,
            title: strings.currentRun,
            correct: currentCorrect,
            total: currentAttempts,
            isVertical: false,
          ),
        ),
        Container(
          width: 2,
          height: 80,
          color: AppConfig.colors.border,
          margin:
              EdgeInsets.symmetric(horizontal: AppConfig.layout.spacingLarge),
        ),
        Expanded(
          child: _buildStatisticsCard(
            icon: Icons.history,
            title: strings.overallStats,
            correct: totalCorrect,
            total: totalAttempts,
            isVertical: false,
          ),
        ),
      ],
    );
  }

  // Statistik-Karte
  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required int correct,
    required int total,
    required bool isVertical,
  }) {
    final percentage = total > 0 ? (correct / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppConfig.colors.textPrimary,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: isVertical ? 16 : 12),
        Row(
          children: [
            Text(
              '$correct/$total',
              style: AppConfig.textStyles.bodyLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '(${percentage.toStringAsFixed(0)}%)',
              style: AppConfig.textStyles.bodyLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppConfig.colors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 24,
          decoration: BoxDecoration(
            color: AppConfig.colors.backgroundDark,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppConfig.colors.border,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConfig.colors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
