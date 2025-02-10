import 'package:flutter/material.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';
import '../config/config.dart';
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
    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConfig.layout.screenPaddingHorizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: AppConfig.layout.spacingXLarge),
                _buildContent(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dispatchGameEvent(context, const ShowLogin()),
        icon: const Icon(Icons.login),
        label: Text(AppConfig.strings.introduction.loginButton),
        backgroundColor: AppConfig.colors.primary,
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      AppConfig.strings.introduction.title,
      style: AppConfig.textStyles.h1,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppConfig.layout.breakpointTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLeftColumn()),
              SizedBox(width: AppConfig.layout.spacingXLarge),
              Expanded(child: _buildRightColumn(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(),
              SizedBox(height: AppConfig.layout.spacingXLarge),
              _buildRightColumn(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildLeftColumn() {
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
            AppConfig.strings.introduction.challenge,
            style: AppConfig.textStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConfig.strings.introduction.subtitle,
          style: AppConfig.textStyles.bodyLarge,
        ),
        SizedBox(height: AppConfig.layout.spacingMedium),
        Text(
          AppConfig.strings.introduction.description,
          style: AppConfig.textStyles.bodyMedium,
        ),
        SizedBox(height: AppConfig.layout.spacingXLarge),
        _buildQuickStartButton(context),
      ],
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return Center(
      child: PulsingButton(
        onPressed: () => dispatchGameEvent(context, const QuickStartGame()),
        text: AppConfig.strings.introduction.startButton,
      ),
    );
  }
}
