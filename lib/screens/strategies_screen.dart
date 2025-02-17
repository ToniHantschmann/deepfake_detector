import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../models/strategy_model.dart';
import '../widgets/detection_strategies/strategy_carousel/strategy_carousel.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/tutorial/swipe_tutorial_overlay.dart';
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
        previous.generatedPin != current.generatedPin ||
        previous.currentStrategyIndex != current.currentStrategyIndex;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
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

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppConfig.colors.background,
          body: Column(
            children: [
              ProgressBar(currentScreen: state.currentScreen),
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppConfig.layout.screenPaddingHorizontal,
                                vertical:
                                    AppConfig.layout.screenPaddingVertical,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConfig.strings.statistics.title,
                                    style: AppConfig.textStyles.h2,
                                  ),
                                  SizedBox(
                                      height: AppConfig.layout.spacingSmall),
                                  Text(
                                    AppConfig.strings.statistics.subtitle,
                                    style: AppConfig.textStyles.bodyMedium
                                        .copyWith(
                                      color: AppConfig.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Carousel
                            Expanded(
                              child: StrategyCarousel(
                                strategies: [
                                  ...implementedStrategies,
                                  ...dummyStrategies
                                ],
                                onPageChanged: (index) {
                                  context.read<GameBloc>().add(
                                        StrategyIndexChanged(index),
                                      );
                                },
                              ),
                            ),
                            // Next Game Button
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppConfig.layout.screenPaddingHorizontal,
                                vertical: AppConfig.layout.spacingLarge,
                              ),
                              child: _buildNextButton(context),
                            ),
                          ],
                        );
                      },
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
        ),
        // Tutorial Overlay
        if (state.isTemporarySession &&
            state.userStatistics != null &&
            state.userStatistics!.totalAttempts == 0)
          SwipeTutorialOverlay(
            onComplete: () {
              // Tutorial will automatically hide after completion
            },
          ),
      ],
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
