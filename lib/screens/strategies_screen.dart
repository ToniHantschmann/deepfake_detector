import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/detection_strategies/strategy_card.dart';
import '../widgets/detection_strategies/blinking_animation.dart';
import '../widgets/detection_strategies/skin_texture_animation.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/config.dart';
import 'base_game_screen.dart';
import 'pin_overlay.dart';

class StrategiesScreen extends BaseGameScreen {
  const StrategiesScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.currentPin != current.currentPin ||
        previous.generatedPin != current.generatedPin;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    // Show PIN overlay if a new PIN was generated
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
                        Text(
                          AppConfig.strings.statistics.title,
                          style: AppConfig.textStyles.h2,
                        ),
                        SizedBox(height: AppConfig.layout.spacingSmall),
                        Text(
                          AppConfig.strings.statistics.subtitle,
                          style: AppConfig.textStyles.bodyMedium.copyWith(
                            color: AppConfig.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppConfig.layout.spacingXLarge),
                        _buildStrategiesGrid(context),
                        SizedBox(height: AppConfig.layout.spacingLarge),
                        _buildTipCard(),
                        SizedBox(height: AppConfig.layout.spacingXLarge * 2),
                        _buildNextButton(context),
                        SizedBox(height: AppConfig.layout.spacingXLarge),
                      ],
                    ),
                  ),
                ),
                NavigationButtons.forGameScreen(
                  onBack: () => handleBackNavigation(context),
                  currentScreen: GameScreen.statistics,
                ),
                if (state.currentPin == null) _buildRegisterButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > AppConfig.layout.breakpointTablet
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBlinkingStrategy()),
                  SizedBox(width: AppConfig.layout.spacingLarge),
                  Expanded(child: _buildSkinTextureStrategy()),
                ],
              )
            : Column(
                children: [
                  _buildBlinkingStrategy(),
                  SizedBox(height: AppConfig.layout.spacingLarge),
                  _buildSkinTextureStrategy(),
                ],
              );
      },
    );
  }

  Widget _buildBlinkingStrategy() {
    return StrategyCard(
      title: AppConfig.strings.statistics.blinkingTitle,
      description: AppConfig.strings.statistics.blinkingDescription,
      child: const BlinkingAnimation(),
    );
  }

  Widget _buildSkinTextureStrategy() {
    return StrategyCard(
      title: AppConfig.strings.statistics.skinTextureTitle,
      description: AppConfig.strings.statistics.skinTextureDescription,
      child: const SkinTextureAnimation(),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.cardPadding),
      decoration: BoxDecoration(
        color: AppConfig.colors.cardBackground,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        border: Border.all(
          color: AppConfig.colors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppConfig.colors.warning,
            size: 24,
          ),
          SizedBox(width: AppConfig.layout.spacingMedium),
          Expanded(
            child: Text(
              AppConfig.strings.statistics.tip,
              style: AppConfig.textStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 80,
        child: ElevatedButton(
          onPressed: () => handleNextNavigation(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.colors.primary,
            padding: EdgeInsets.symmetric(
              vertical: AppConfig.layout.spacingLarge,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(
            AppConfig.strings.statistics.nextGameButton,
            style: AppConfig.textStyles.buttonLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Positioned(
      right: AppConfig.layout.spacingMedium,
      bottom: AppConfig.layout.spacingMedium,
      child: FloatingActionButton.extended(
        onPressed: () => context.read<GameBloc>().add(const GeneratePin()),
        icon: const Icon(Icons.pin_outlined),
        label: Text(
          AppConfig.strings.statistics.getPinButton,
          style: AppConfig.textStyles.buttonMedium,
        ),
        backgroundColor: AppConfig.colors.primary,
      ),
    );
  }
}
