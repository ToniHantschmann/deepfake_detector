// lib/screens/statistics_screen.dart - Überarbeitete Version mit Donut-Charts
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_language_extension.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/common/donut_chart.dart'; // Importiere das neue Widget
import '../config/app_config.dart';
import '../config/localization/string_types.dart';
import 'base_game_screen.dart';
import '../widgets/overlay/pin_overlay.dart';

class StatisticsScreen extends BaseGameScreen {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.currentPin != current.currentPin ||
        previous.generatedPin != current.generatedPin ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(context.currentLocale).result;

    if (state.status == GameStatus.loading || state.userStatistics == null) {
      return Scaffold(
        backgroundColor: AppConfig.colors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppConfig.colors.primary,
          ),
        ),
      );
    }

    // PIN-Overlay anzeigen, wenn ein PIN generiert wurde
    if (state.generatedPin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: AppConfig.colors.backgroundDark.withOpacity(0.8),
          builder: (dialogContext) => BlocProvider.value(
            value: context.read<GameBloc>(),
            child: PinOverlay(
              pin: state.generatedPin.toString(),
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      });
    }

    // Statistiken abrufen
    final currentCorrect = state.userStatistics!.recentAttempts
        .where((attempt) => attempt.wasCorrect)
        .length;
    final currentAttempts = state.userStatistics!.recentAttempts.length;
    final totalCorrect = state.userStatistics!.correctGuesses;
    final totalAttempts = state.userStatistics!.totalAttempts;

    // Viewed video pairs statistics
    final viewedPairs = state.userStatistics!.seenPairIds.length;
    final totalPairs = state.totalUniquePairs;

    // Ensure totalPairs is never zero to avoid division by zero
    final safeTotal = totalPairs > 0 ? totalPairs : max(viewedPairs, 1);

    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProgressBar(currentScreen: state.currentScreen),
            Expanded(
              child: Stack(
                children: [
                  // Hauptinhalt
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.layout.screenPaddingHorizontal,
                      vertical: AppConfig.layout.screenPaddingVertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          "Deine Statistiken",
                          style: AppConfig.textStyles.h2,
                        ),
                        SizedBox(height: AppConfig.layout.spacingMedium),
                        Text(
                          "Übersicht über deine Leistung",
                          style: AppConfig.textStyles.bodyLarge.copyWith(
                            color: AppConfig.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppConfig.layout.spacingXLarge),

                        // Statistik-Karten in einer Row mit Responsive Layout
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Determine if we should use horizontal or vertical layout
                              final isWideScreen = constraints.maxWidth > 900;

                              // Liste der StatistiK-Widgets
                              final List<Widget> statsCards = [];

                              // 1. Aktueller Durchgang (immer anzeigen)
                              statsCards.add(
                                Expanded(
                                  child: _buildStatisticsCard(
                                    icon: Icons.straighten,
                                    title: strings.currentRun,
                                    correct: currentCorrect,
                                    total: currentAttempts,
                                    useThresholdColors: true,
                                    context: context,
                                  ),
                                ),
                              );

                              // 2. Gesamtstatistik (falls PIN vorhanden)
                              if (state.currentPin != null) {
                                statsCards.add(
                                  SizedBox(
                                    width: isWideScreen
                                        ? AppConfig.layout.spacingLarge
                                        : 0,
                                    height: isWideScreen
                                        ? 0
                                        : AppConfig.layout.spacingLarge,
                                  ),
                                );
                                statsCards.add(
                                  Expanded(
                                    child: _buildStatisticsCard(
                                      icon: Icons.history,
                                      title: strings.overallStats,
                                      correct: totalCorrect,
                                      total: totalAttempts,
                                      useThresholdColors: true,
                                      context: context,
                                    ),
                                  ),
                                );
                              }

                              // 3. Video Pairs Progress (immer anzeigen)
                              statsCards.add(
                                SizedBox(
                                  width: isWideScreen
                                      ? AppConfig.layout.spacingLarge
                                      : 0,
                                  height: isWideScreen
                                      ? 0
                                      : AppConfig.layout.spacingLarge,
                                ),
                              );
                              statsCards.add(
                                Expanded(
                                  child: _buildVideoPairsCard(
                                    viewedPairs: viewedPairs,
                                    totalPairs: safeTotal,
                                    context: context,
                                  ),
                                ),
                              );

                              // Return horizontal or vertical layout based on screen width
                              if (isWideScreen) {
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: statsCards,
                                );
                              } else {
                                return Column(
                                  children: statsCards.map((widget) {
                                    // Für Column-Layout geben wir den Expanded-Widgets eine feste Höhe
                                    if (widget is Expanded) {
                                      return SizedBox(
                                        height:
                                            400, // Feste Höhe für mobile Ansicht
                                        child: widget.child,
                                      );
                                    }
                                    return widget;
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ),

                        // Buttons wie im StrategiesScreen
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConfig.layout.spacingLarge,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Nächstes Spiel Button (links)
                              _buildActionButton(
                                onPressed: () => _handleNextGame(context),
                                text: "Nächstes Spiel",
                                icon: Icons.play_arrow,
                                color: AppConfig.colors.primary,
                              ),

                              // Platzhalter zwischen Buttons, nur wenn PIN-Button angezeigt wird
                              if (state.currentPin == null)
                                SizedBox(width: AppConfig.layout.spacingXLarge),

                              // PIN Button (rechts), nur wenn kein PIN vorhanden
                              if (state.currentPin == null)
                                _buildActionButton(
                                  onPressed: () =>
                                      _handlePinGeneration(context),
                                  text: "PIN generieren",
                                  icon: Icons.pin_outlined,
                                  color: AppConfig.colors.secondary,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation Button (nur Next, kein Back)
                  NavigationButtons.forGameScreen(
                    onBack: () => handleBackNavigation(context),
                    currentScreen: state.currentScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePinGeneration(BuildContext context) {
    context.read<GameBloc>().add(const GeneratePin());
  }

  void _handleNextGame(BuildContext context) {
    context.read<GameBloc>().add(const RestartGame());
  }

  // Action Button im Stil des StrategiesScreens
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 600,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: AppConfig.textStyles.buttonLarge,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }

  // Überarbeitete Statistik-Karte mit Donut-Chart
  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required int correct,
    required int total,
    bool useThresholdColors = false,
    required BuildContext context,
  }) {
    final percentage = total > 0 ? (correct / total * 100) : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height > 600 ? double.infinity : null,
      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Icon und Titel
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppConfig.colors.textPrimary,
              ),
              SizedBox(width: 12),
              Expanded(
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

          SizedBox(height: 20),

          // Erweiterter Bereich für die Chart-Darstellung
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Zahlen mittig angeordnet
                    Text(
                      'Korrekte Antworten:',
                      style: AppConfig.textStyles.bodyMedium.copyWith(
                        color: AppConfig.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$correct von $total',
                      style: AppConfig.textStyles.bodyLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    // Großer, zentrierter Donut-Chart
                    DonutChart(
                      percentage: percentage,
                      size: 180, // Deutlich größer
                      strokeWidth: 16, // Etwas dicker für bessere Sichtbarkeit
                      backgroundColor: AppConfig.colors.backgroundDark,
                      useThresholdColors: useThresholdColors,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Überarbeitete Videopaare-Karte mit Donut-Chart
  Widget _buildVideoPairsCard({
    required int viewedPairs,
    required int totalPairs,
    required BuildContext context,
  }) {
    final percentage = totalPairs > 0 ? (viewedPairs / totalPairs * 100) : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height > 600 ? double.infinity : null,
      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Icon und Titel
          Row(
            children: [
              Icon(
                Icons.video_library,
                size: 24,
                color: AppConfig.colors.textPrimary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Gesehene Videopaare",
                  style: AppConfig.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Erweiterter Bereich für die Chart-Darstellung
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Zahlen mittig angeordnet
                    Text(
                      'Fortschritt:',
                      style: AppConfig.textStyles.bodyMedium.copyWith(
                        color: AppConfig.colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$viewedPairs von $totalPairs',
                      style: AppConfig.textStyles.bodyLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    // Großer, zentrierter Donut-Chart
                    DonutChart(
                      percentage: percentage,
                      size: 180, // Deutlich größer
                      strokeWidth: 16, // Etwas dicker für bessere Sichtbarkeit
                      backgroundColor: AppConfig.colors.backgroundDark,
                      // Hier verwenden wir die Standard-Farbe (blau)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
