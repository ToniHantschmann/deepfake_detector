import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../config/localization/string_types.dart';
import '../widgets/common/language_selector.dart';
import 'base_game_screen.dart';
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
        previous.status != current.status;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(context.currentLocale).introduction;
    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.all(AppConfig.layout.screenPaddingHorizontal),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(strings),
                    SizedBox(height: AppConfig.layout.spacingXLarge),
                    _buildContent(context, strings),
                  ],
                ),
              ),
            ),
            // Sprachauswahl in der oberen rechten Ecke
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
      style: AppConfig.textStyles.h1,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent(
      BuildContext context, IntroductionScreenStrings strings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppConfig.layout.breakpointTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLeftColumn(strings)),
              SizedBox(width: AppConfig.layout.spacingXLarge),
              Expanded(child: _buildRightColumn(context, strings)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(strings),
              SizedBox(height: AppConfig.layout.spacingXLarge),
              _buildRightColumn(context, strings),
            ],
          );
        }
      },
    );
  }

  Widget _buildLeftColumn(IntroductionScreenStrings strings) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: AppConfig.video.minAspectRatio,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
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

  Widget _buildRightColumn(
      BuildContext context, IntroductionScreenStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.subtitle,
          style: AppConfig.textStyles.bodyLarge,
        ),
        SizedBox(height: AppConfig.layout.spacingMedium),
        Text(
          strings.description,
          style: AppConfig.textStyles.bodyMedium,
        ),
        SizedBox(height: AppConfig.layout.spacingXLarge),
        _buildQuickStartButton(context, strings),
      ],
    );
  }

  Widget _buildQuickStartButton(
      BuildContext context, IntroductionScreenStrings strings) {
    return Center(
      child: PulsingButton(
        onPressed: () => dispatchGameEvent(context, const QuickStartGame()),
        text: strings.startButton,
      ),
    );
  }
}
