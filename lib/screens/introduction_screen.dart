import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/localization/string_types.dart';
import '../widgets/common/language_selector.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';
import '../config/app_config.dart';
import '../widgets/common/pulsing_button.dart';
import '../widgets/common/pulsing_highlight.dart';

class IntroductionScreen extends BaseGameScreen {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.locale != current.locale; // Check for locale changes
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    // Get strings directly using the state's locale
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
                  // Header at the top
                  SizedBox(height: AppConfig.layout.spacingMedium),
                  _buildHeader(strings),
                  SizedBox(height: AppConfig.layout.spacingXLarge),
                  // Main content in row layout
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
            // Language selector in the top right corner
            Positioned(
              top: AppConfig.layout.spacingMedium,
              right: AppConfig.layout.spacingMedium,
              child: const LanguageSelector(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dispatchGameEvent(context, const ShowLogin()),
        icon: const Icon(Icons.login),
        label: Text(strings.loginButton),
        backgroundColor: AppConfig.colors.primary,
      ),
    );
  }

  Widget _buildHeader(IntroductionScreenStrings strings) {
    return Text(
      strings.title,
      style: AppConfig.textStyles.h1.copyWith(
        fontSize: 64, // Deutlich größerer Titeltext
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLeftColumn(IntroductionScreenStrings strings) {
    return Container(
      child: Column(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'images/deepfakePope.jpeg',
                      fit: BoxFit.cover,
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
      ),
    );
  }

  Widget _buildRightColumnContent(IntroductionScreenStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          strings.subtitle,
          style: AppConfig.textStyles.bodyLarge.copyWith(
            fontSize: 28, // Deutlich größerer Untertitel
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: AppConfig.layout.spacingLarge),
        Text(
          strings.description,
          style: AppConfig.textStyles.bodyMedium.copyWith(
            fontSize: 22, // Deutlich größere Beschreibung
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(
      BuildContext context, IntroductionScreenStrings strings) {
    return Center(
      child: SizedBox(
        height: 100, // Erhöhter Button mit mehr Höhe
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: PulsingButton(
            onPressed: () => dispatchGameEvent(context, const QuickStartGame()),
            text: strings.startButton,
          ),
        ),
      ),
    );
  }
}
