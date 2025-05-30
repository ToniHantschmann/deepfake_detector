import 'package:deepfake_detector/blocs/game/game_bloc.dart';
import 'package:deepfake_detector/mixins/game_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/localization/string_types.dart';
import '../constants/overlay_types.dart';
import '../widgets/overlays/confidence_survey_overlay.dart';
import '../widgets/overlays/login_overlay.dart';
import '../widgets/common/language_selector.dart';
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
    return _IntroductionScreenContent(state: state);
  }
}

class _IntroductionScreenContent extends StatefulWidget {
  final GameState state;

  const _IntroductionScreenContent({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<_IntroductionScreenContent> createState() =>
      _IntroductionScreenContentState();
}

class _IntroductionScreenContentState extends State<_IntroductionScreenContent>
    with GameNavigationMixin {
  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(widget.state.locale).introduction;

    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Listener für waitingForSurvey Status - zeigt automatisch die Survey an
        if (state.status == GameStatus.waitingForSurvey &&
            !state.hasOverlayBeenShown(OverlayType.confidenceSurvey)) {
          _showConfidenceSurvey(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppConfig.colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.all(AppConfig.layout.screenPaddingHorizontal),
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

              // Add Language Selector to the top right corner
              Positioned(
                top: 16.0,
                right: 16.0,
                child: const LanguageSelector(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showLoginDialog(context),
          icon: const Icon(Icons.login),
          label: Text(
            strings.loginButton,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppConfig.colors.primary,
          extendedPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        ),
      ),
    );
  }

  // Login Dialog direkt im IntroductionScreen behandeln
  Future<void> _showLoginDialog(BuildContext context) async {
    final bloc = context.read<GameBloc>();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const LoginOverlay(),
      ),
    );

    // Reagiere auf das Ergebnis des Login Dialogs
    if (result == 'continue_without_pin') {
      debugPrint("quickStartGame wird aufgerufen");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleStartGame(context);
        }
      });
    }
    // Bei result == 'success' ist der Nutzer bereits eingeloggt und das Spiel läuft
    // Bei result == null wurde der Dialog abgebrochen - nichts zu tun
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
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MorphingAnimation(
                    realImagePath: 'assets/images/real_Pope.jpg',
                    fakeImagePath: 'assets/images/deepfake_Pope.jpg',
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
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
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
        ..._buildNumberedList(strings.steps),
      ],
    );
  }

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
    final gameBloc = context.read<GameBloc>();
    final bool showSurvey =
        !gameBloc.state.hasOverlayBeenShown(OverlayType.confidenceSurvey);

    if (showSurvey) {
      _showConfidenceSurvey(context);
    } else {
      handleQuickstartGame(context);
    }
  }

  // Confidence Survey anzeigen
  void _showConfidenceSurvey(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: gameBloc,
        child: ConfidenceSurveyDialog(
          onComplete: () {
            Navigator.of(dialogContext).pop();
            gameBloc.add(const QuickStartGame());
          },
        ),
      ),
    );
  }
}
