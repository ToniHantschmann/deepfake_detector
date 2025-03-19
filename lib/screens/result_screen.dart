import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_language_extension.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';
import '../config/localization/string_types.dart';
import 'base_game_screen.dart';
import '../widgets/overlay/video_player_overlay.dart';
import '../constants/overlay_types.dart';
import '../widgets/tutorial/video_tap_tutorial.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    // Prüfen, ob das Tutorial angezeigt werden soll
    bool showTutorial = state.isTemporarySession &&
        state.userStatistics != null &&
        !state.hasOverlayBeenShown(OverlayType.videoTap) &&
        state.userStatistics!.totalAttempts <= 2;

    return _ResultScreenContent(
      state: state,
      strings: strings,
      showTutorial: showTutorial,
      onTutorialComplete: () => completeTutorial(context, OverlayType.videoTap),
      onNextNavigation: () => handleNextNavigation(context),
    );
  }
}

class _ResultScreenContent extends StatefulWidget {
  final GameState state;
  final ResultScreenStrings strings;
  final bool showTutorial;
  final VoidCallback onTutorialComplete;
  final VoidCallback onNextNavigation;

  const _ResultScreenContent({
    Key? key,
    required this.state,
    required this.strings,
    required this.showTutorial,
    required this.onTutorialComplete,
    required this.onNextNavigation,
  }) : super(key: key);

  @override
  State<_ResultScreenContent> createState() => _ResultScreenContentState();
}

class _ResultScreenContentState extends State<_ResultScreenContent> {
  // Lokaler Override, der das Tutorial sofort ausblenden kann
  bool _showTutorialOverride = true;

  void _handleTutorialComplete() {
    setState(() {
      _showTutorialOverride = false;
    });
    widget.onTutorialComplete();
  }

  @override
  Widget build(BuildContext context) {
    // Bestimme basierend auf der Bildschirmbreite, ob wir horizontal oder vertikal layouten
    final isHorizontalLayout = MediaQuery.of(context).size.width >= 700;

    if (widget.state.status == GameStatus.loading ||
        widget.state.userGuessIsDeepfake == null ||
        widget.state.isCorrectGuess == null ||
        widget.state.videos.isEmpty) {
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
    final shownVideo = widget.state.videos.first;
    final counterpartVideo =
        widget.state.videos.length > 1 ? widget.state.videos[1] : null;

    // Bestimme, welches Video das Deepfake ist (für die Indikatoren)
    final deepfakeVideo = shownVideo.isDeepfake ? shownVideo : counterpartVideo;
    final hasDeepfakeIndicators =
        deepfakeVideo != null && deepfakeVideo.isDeepfake;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppConfig.colors.background,
          body: Column(
            children: [
              // Progress Bar oben
              ProgressBar(currentScreen: widget.state.currentScreen),

              // Hauptinhalt
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Wir verwenden LayoutBuilder um genaue Größen zu bekommen
                    return Stack(
                      children: [
                        // Statischer Inhalt in einer begrenzten Box
                        Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              Padding(
                                padding: EdgeInsets.all(
                                    AppConfig.layout.screenPaddingHorizontal),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ergebnis-Header
                                    _buildResultHeader(
                                        widget.state.isCorrectGuess!,
                                        widget.strings),
                                  ],
                                ),
                              ),

                              // Videos Section mit fester Höhe von 50% im horizontalen Layout
                              Container(
                                height: isHorizontalLayout
                                    ? constraints.maxHeight * 0.5
                                    : // 50% im horizontalen Layout
                                    constraints.maxHeight *
                                        0.45, // 45% im vertikalen Layout
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.layout.screenPaddingHorizontal,
                                ),
                                child: counterpartVideo != null
                                    ? isHorizontalLayout
                                        ? _buildHorizontalVideoComparison(
                                            shownVideo,
                                            counterpartVideo,
                                            widget.state.isCorrectGuess!,
                                            widget.state.userGuessIsDeepfake!,
                                            context,
                                            widget.strings)
                                        : _buildVerticalVideoComparison(
                                            shownVideo,
                                            counterpartVideo,
                                            widget.state.isCorrectGuess!,
                                            widget.state.userGuessIsDeepfake!,
                                            context,
                                            widget.strings)
                                    : Container(), // Fallback wenn kein counterpartVideo
                              ),

                              // Indikatoren Section
                              if (hasDeepfakeIndicators)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppConfig
                                        .layout.screenPaddingHorizontal),
                                    child: _buildDeepfakeIndicatorsCard(
                                        deepfakeVideo, widget.strings, context),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Navigation Buttons
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: NavigationButtons.forGameScreen(
                              onNext: widget.onNextNavigation,
                              currentScreen: widget.state.currentScreen,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Tutorial Overlay, falls aktiviert
        if (widget.showTutorial && _showTutorialOverride)
          VideoTapTutorialOverlay(
            onComplete: _handleTutorialComplete,
          ),
      ],
    );
  }

  // Horizontales Layout für die Videokarten
  Widget _buildHorizontalVideoComparison(
    Video shownVideo,
    Video counterpartVideo,
    bool isCorrect,
    bool userGuessIsDeepfake,
    BuildContext context,
    ResultScreenStrings strings,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildVideoCard(
            video: shownVideo,
            isDeepfake: shownVideo.isDeepfake,
            title: strings.shownVideoTitle,
            context: context,
            strings: strings,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildVideoCard(
            video: counterpartVideo,
            isDeepfake: counterpartVideo.isDeepfake,
            title: strings.comparisonVideoTitle,
            context: context,
            strings: strings,
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
    ResultScreenStrings strings,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildVideoCard(
            video: shownVideo,
            isDeepfake: shownVideo.isDeepfake,
            title: strings.shownVideoTitle,
            context: context,
            strings: strings,
          ),
        ),
        const SizedBox(height: 12.0),
        Expanded(
          child: _buildVideoCard(
            video: counterpartVideo,
            isDeepfake: counterpartVideo.isDeepfake,
            title: strings.comparisonVideoTitle,
            context: context,
            strings: strings,
          ),
        ),
      ],
    );
  }

  // Neue Card für die Deepfake-Indikatoren
  Widget _buildDeepfakeIndicatorsCard(
      Video deepfakeVideo, ResultScreenStrings strings, BuildContext context) {
    // Die lokalisierten Gründe aus dem AppConfig holen
    final localizedReasons = AppConfig.getStrings(context.currentLocale)
        .deepfakeReasons
        .getReasonsForVideo(deepfakeVideo.id);

    return Container(
      width: double.infinity, // Volle Breite
      height: double.infinity, // Volle verfügbare Höhe
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        border: Border.all(
          color: AppConfig.colors.warning,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Titel
          Container(
            padding: EdgeInsets.all(AppConfig.layout.spacingMedium),
            decoration: BoxDecoration(
              color: AppConfig.colors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConfig.layout.cardRadius - 2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppConfig.colors.warning,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  strings.explanationTitle,
                  style: AppConfig.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConfig.colors.warning,
                  ),
                ),
              ],
            ),
          ),

          // Liste der Indikatoren
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConfig.layout.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: localizedReasons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reasonText = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppConfig.colors.warning,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reasonText,
                            style: AppConfig.textStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
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
            locale: context.currentLocale,
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

  // Videokarte
  Widget _buildVideoCard({
    required Video video,
    required bool isDeepfake,
    required String title,
    required BuildContext context,
    required ResultScreenStrings strings,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titel
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppConfig.textStyles.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Thumbnail
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppConfig.layout.cardRadius - 2),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showVideoOverlay(context, video),
                      highlightColor: Colors.white.withOpacity(0.1),
                      splashColor: AppConfig.colors.primary.withOpacity(0.3),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: AppConfig.video.minAspectRatio,
                            child: Image.asset(
                              video.thumbnailUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Status-Indikator oben rechts
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        const SizedBox(width: 4),
                        Text(
                          isDeepfake
                              ? strings.deepfakeIndicator
                              : strings.realVideoIndicator,
                          style: const TextStyle(
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppConfig.colors.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
}
