import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_language_extension.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';
import '../config/localization/string_types.dart';
import 'base_game_screen.dart';
import 'pin_overlay.dart';

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

                        // Statistik-Karten
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildStatisticsCard(
                                  icon: Icons.straighten,
                                  title: strings.currentRun,
                                  correct: currentCorrect,
                                  total: currentAttempts,
                                ),
                                SizedBox(height: AppConfig.layout.spacingLarge),
                                _buildStatisticsCard(
                                  icon: Icons.history,
                                  title: strings.overallStats,
                                  correct: totalCorrect,
                                  total: totalAttempts,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppConfig.layout.spacingLarge,
                          ),
                          child: Column(
                            children: [
                              // PIN Button (nur wenn kein PIN vorhanden)
                              if (state.currentPin == null)
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                    bottom: AppConfig.layout.spacingMedium,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _handlePinGeneration(context),
                                    icon: const Icon(Icons.pin_outlined),
                                    label: Text(
                                      "Ergebnisse speichern (PIN generieren)",
                                      style: AppConfig.textStyles.buttonMedium,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConfig.colors.primary,
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            AppConfig.layout.spacingMedium,
                                      ),
                                    ),
                                  ),
                                ),

                              // Nächstes Spiel Button
                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _handleNextGame(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConfig.colors.success,
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppConfig.layout.spacingMedium,
                                    ),
                                  ),
                                  child: Text(
                                    "Nächstes Spiel",
                                    style: AppConfig.textStyles.buttonLarge,
                                  ),
                                ),
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

  // Statistik-Karte Widget
  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required int correct,
    required int total,
  }) {
    final percentage = total > 0 ? (correct / total * 100) : 0.0;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppConfig.colors.textPrimary,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                '$correct/$total',
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '(${percentage.toStringAsFixed(0)}%)',
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
      ),
    );
  }
}
