import 'package:deepfake_detector/blocs/game/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/localization/string_types.dart';
import '../constants/overlay_types.dart';
import '../widgets/overlays/confidence_survey_overlay.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';
import '../config/app_config.dart';
import '../widgets/intro/pulsing_button.dart';
import '../widgets/intro/pulsing_highlight.dart';
import '../widgets/intro/morphing_animation.dart';

class IntroductionScreen extends BaseGameScreen {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(state.locale).introduction;

    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(AppConfig.layout.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppConfig.layout.spacingMedium),
                  _buildHeader(strings),
                  SizedBox(height: AppConfig.layout.spacingXLarge),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildLeftColumn(strings),
                        ),
                        SizedBox(width: AppConfig.layout.spacingXLarge),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRightColumnContent(strings),
                              SizedBox(
                                  height: AppConfig.layout.spacingXLarge * 2),
                              _buildQuickStartButton(context, strings),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dispatchGameEvent(context, const ShowLogin()),
        icon: const Icon(Icons.login),
        label: Text(
          strings.loginButton,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Größere Schrift
          ),
        ),
        backgroundColor: AppConfig.colors.primary,
        // Größerer Button
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      ),
    );
  }

  Widget _buildHeader(IntroductionScreenStrings strings) {
    return Text(
      strings.title,
      style: AppConfig.textStyles.h1.copyWith(
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLeftColumn(IntroductionScreenStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.0),
          child: AspectRatio(
            aspectRatio: AppConfig.video.minAspectRatio,
            child: PulsingHighlight(
              color: AppConfig.colors.primary,
              maxBlurRadius: 30,
              maxSpreadRadius: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppConfig.colors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConfig.colors.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                // Hier haben wir das einfache Image durch die Morphing-Animation ersetzt
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MorphingAnimation(
                    realImagePath: 'images/real_Pope.jpg',
                    fakeImagePath: 'images/deepfake_Pope.jpg',
                    duration: const Duration(seconds: 3),
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppConfig.layout.spacingMedium),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.0),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingMedium,
            horizontal: AppConfig.layout.spacingLarge,
          ),
          decoration: BoxDecoration(
            color: AppConfig.colors.wrongAnswer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            strings.challenge,
            style: AppConfig.textStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumnContent(IntroductionScreenStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(strings.subtitle,
            style: AppConfig.textStyles.h3.copyWith(fontSize: 36)),
        SizedBox(height: AppConfig.layout.spacingLarge),
        // Nummerierte Liste aus Konfiguration-Strings
        ..._buildNumberedList(strings.steps),
      ],
    );
  }

  // Hilfsmethode zum Erstellen der nummerierten Liste
  List<Widget> _buildNumberedList(List<String> items) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: AppConfig.layout.spacingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}. ",
              style: AppConfig.textStyles.bodyMedium.copyWith(
                fontSize: 28,
                height: 1.4,
                fontWeight: FontWeight.bold,
                color: AppConfig.colors.primary,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: AppConfig.textStyles.bodyMedium.copyWith(
                  fontSize: 28,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildQuickStartButton(
      BuildContext context, IntroductionScreenStrings strings) {
    return Center(
      child: SizedBox(
        height: 100,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: PulsingButton(
            onPressed: () => _handleStartGame(context),
            text: strings.startButton,
          ),
        ),
      ),
    );
  }

  void _handleStartGame(BuildContext context) {
    // Zuerst prüfen, ob die Umfrage bereits gezeigt wurde
    final gameBloc = context.read<GameBloc>();
    final bool showSurvey =
        !gameBloc.state.hasOverlayBeenShown(OverlayType.confidenceSurvey);

    if (showSurvey) {
      // Sofort Dialog anzeigen, ohne vorher den State zu ändern
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider.value(
          value: gameBloc,
          child: ConfidenceSurveyDialog(
            onComplete: () {
              // Dialog schließen
              Navigator.of(dialogContext).pop();

              // Jetzt das Spiel starten, nachdem die Umfrage abgeschlossen wurde
              // Die Events SetInitialConfidenceRating und OverlayCompleted werden bereits
              // in _handleSubmit() der ConfidenceSurveyDialog-Klasse gesendet
              gameBloc.add(const QuickStartGame());
            },
          ),
        ),
      );
    } else {
      // Wenn keine Umfrage nötig ist, einfach das Spiel starten
      dispatchGameEvent(context, const QuickStartGame());
    }
  }
}
