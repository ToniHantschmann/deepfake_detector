// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_language_extension.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';
import '../config/localization/string_types.dart';
import 'base_game_screen.dart';

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
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.layout.screenPaddingHorizontal,
                      vertical: AppConfig.layout.screenPaddingVertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultHeader(state.isCorrectGuess!, strings),
                        SizedBox(height: AppConfig.layout.spacingLarge),

                        // Video-Vergleich hinzufügen
                        if (counterpartVideo != null) ...[
                          Text(
                            "Video-Vergleich",
                            style: AppConfig.textStyles.h3,
                          ),
                          SizedBox(height: AppConfig.layout.spacingMedium),
                          _buildVideoComparison(
                              shownVideo,
                              counterpartVideo,
                              state.isCorrectGuess!,
                              state.userGuessIsDeepfake!),
                        ],

                        // Reduced padding for the fixed bottom panel
                        SizedBox(
                            height:
                                80), // Just enough space for the stats panel
                      ],
                    ),
                  ),
                ),
                NavigationButtons.forGameScreen(
                  onNext: () => handleNextNavigation(context),
                  currentScreen: GameScreen.result,
                ),
                _buildStatisticsPanel(state, strings),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            size: 36, // Kleiner als vorher
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

  // Verbesserter Video-Vergleich mit kompakteren Karten
  Widget _buildVideoComparison(Video shownVideo, Video counterpartVideo,
      bool isCorrectGuess, bool userGuessIsDeepfake) {
    return LayoutBuilder(builder: (context, constraints) {
      // Für schmale Bildschirme stapeln wir die Karten vertikal
      final isNarrow = constraints.maxWidth < 500;

      if (isNarrow) {
        return Column(
          children: [
            _buildVideoCard(
              video: shownVideo,
              isDeepfake: shownVideo.isDeepfake,
              userGuessIsDeepfake: userGuessIsDeepfake,
              title: "Gezeigtes Video",
            ),
            SizedBox(height: AppConfig.layout.spacingMedium),
            _buildVideoCard(
              video: counterpartVideo,
              isDeepfake: counterpartVideo.isDeepfake,
              userGuessIsDeepfake: null,
              title: "Vergleichsvideo",
            ),
          ],
        );
      } else {
        // Für breitere Bildschirme zeigen wir sie nebeneinander
        return Row(
          children: [
            Expanded(
              child: _buildVideoCard(
                video: shownVideo,
                isDeepfake: shownVideo.isDeepfake,
                userGuessIsDeepfake: userGuessIsDeepfake,
                title: "Gezeigtes Video",
              ),
            ),
            SizedBox(width: AppConfig.layout.spacingMedium),
            Expanded(
              child: _buildVideoCard(
                video: counterpartVideo,
                isDeepfake: counterpartVideo.isDeepfake,
                userGuessIsDeepfake: null,
                title: "Vergleichsvideo",
              ),
            ),
          ],
        );
      }
    });
  }

  // Kompaktere Video-Karte
  Widget _buildVideoCard({
    required Video video,
    required bool isDeepfake,
    bool? userGuessIsDeepfake,
    required String title,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titel
          Padding(
            padding: EdgeInsets.all(8.0), // Kleiner als vorher
            child: Text(
              title,
              style: AppConfig.textStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),

          // Vorschaubild
          AspectRatio(
            aspectRatio: AppConfig.video.minAspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConfig.layout.cardRadius - 2),
              ),
              child: Image.asset(
                video.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Deepfake-Status und ggf. Nutzerentscheidung
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ), // Kleiner als vorher
            decoration: BoxDecoration(
              color: isDeepfake
                  ? AppConfig.colors.warning.withOpacity(0.2)
                  : AppConfig.colors.success.withOpacity(0.2),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppConfig.layout.cardRadius - 2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDeepfake ? Icons.warning : Icons.check_circle,
                      color: isDeepfake
                          ? AppConfig.colors.warning
                          : AppConfig.colors.success,
                      size: 16, // Kleiner als vorher
                    ),
                    SizedBox(width: 4), // Kleiner als vorher
                    Flexible(
                      child: Text(
                        isDeepfake ? "Deepfake" : "Echtes Video",
                        style: AppConfig.textStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDeepfake
                              ? AppConfig.colors.warning
                              : AppConfig.colors.success,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Nur für das gezeigte Video die Nutzerentscheidung anzeigen
                if (userGuessIsDeepfake != null) ...[
                  SizedBox(height: 4), // Kleiner als vorher
                  Text(
                    "Deine Entscheidung: " +
                        (userGuessIsDeepfake ? "Deepfake" : "Echt"),
                    style: AppConfig.textStyles.bodySmall.copyWith(
                      fontSize: 12, // Kleinere Schrift
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Verbesserte Methode für das Statistik-Panel mit ca. 1/5 Bildschirmhöhe
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
        elevation: 12, // Verstärkt von 8 auf 12 für besseren Schatten
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Berechne die Höhe basierend auf der Bildschirmgröße (ca. 1/5 des Bildschirms)
              final double screenHeight = MediaQuery.of(context).size.height;
              final double targetHeight =
                  screenHeight * 0.2; // 1/5 des Bildschirms

              // Responsive Layout: Bei sehr schmalen Geräten vertikales Layout
              final isVeryNarrow =
                  constraints.maxWidth < 500; // Erhöht auf 500px

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConfig.layout.spacingLarge,
                  vertical: AppConfig.layout.spacingLarge,
                ),
                constraints: BoxConstraints(
                  minHeight: targetHeight,
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

// Vertikales Layout für schmale Bildschirme
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

// Horizontales Layout für breitere Bildschirme
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
          height: 80, // Deutlich erhöht
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

// Stark verbesserte Statistik-Karte mit besserer Lesbarkeit und Größe
  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required int correct,
    required int total,
    required bool isVertical,
  }) {
    // Prozentberechnung mit Schutz vor Division durch Null
    final percentage = total > 0 ? (correct / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titel und Icon in einer Zeile mit verbessertem Layout
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24, // Weiter vergrößert auf 24
              color: AppConfig.colors.textPrimary,
            ),
            SizedBox(width: 12), // Vergrößert auf 12
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
        SizedBox(
            height: isVertical ? 16 : 12), // Mehr Abstand im vertikalen Layout

        // Verbesserte Statistikdarstellung
        Row(
          children: [
            // Textliche Darstellung der Statistik
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
                color: AppConfig.colors.primary, // Immer blau
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Überarbeiteter Prozentbalken mit einheitlicher Farbe und Umrandung
        Container(
          width: double.infinity,
          height: 24, // Reduzierte Höhe
          decoration: BoxDecoration(
            color: AppConfig.colors.backgroundDark,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppConfig.colors.border,
              width: 1.5, // Dickere Umrandung für bessere Sichtbarkeit
            ),
          ),
          child: Stack(
            children: [
              // Farbiger Fortschrittsbalken in einheitlichem Blau
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConfig.colors.primary, // Immer blau
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
