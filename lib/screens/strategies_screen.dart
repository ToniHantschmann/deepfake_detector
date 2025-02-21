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
    return _StrategiesScreenContent(state: state);
  }
}

class _StrategiesScreenContent extends StatefulWidget {
  final GameState state;

  const _StrategiesScreenContent({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<_StrategiesScreenContent> createState() =>
      _StrategiesScreenContentState();
}

class _StrategiesScreenContentState extends State<_StrategiesScreenContent> {
  bool _showTutorial = true;

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.state.isTemporarySession &&
        widget.state.userStatistics != null &&
        widget.state.userStatistics!.totalAttempts == 1;
  }

  void _handleTutorialComplete() {
    setState(() {
      _showTutorial = false;
    });
  }

  void _handleNextNavigation() {
    context.read<GameBloc>().add(const NextScreen());
  }

  void _handleBackNavigation() {
    context.read<GameBloc>().add(const PreviousScreen());
  }

  void _handlePinGeneration() {
    context.read<GameBloc>().add(const GeneratePin());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.generatedPin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: AppConfig.colors.backgroundDark.withOpacity(0.8),
          builder: (dialogContext) => BlocProvider.value(
            value: context.read<GameBloc>(),
            child: PinOverlay(
              pin: widget.state.generatedPin.toString(),
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
              ProgressBar(currentScreen: widget.state.currentScreen),
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
                                    AppConfig.strings.strategies.title,
                                    style: AppConfig.textStyles.h2,
                                  ),
                                  SizedBox(
                                      height: AppConfig.layout.spacingSmall),
                                  Text(
                                    AppConfig.strings.strategies.subtitle,
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
                              child: Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 80,
                                  child: ElevatedButton(
                                    onPressed: _handleNextNavigation,
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
                                      AppConfig
                                          .strings.strategies.nextGameButton,
                                      style: AppConfig.textStyles.buttonLarge,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    NavigationButtons.forGameScreen(
                      onBack: _handleBackNavigation,
                      currentScreen: widget.state.currentScreen,
                    ),
                    if (widget.state.currentPin == null)
                      Positioned(
                        right: AppConfig.layout.spacingMedium,
                        bottom: AppConfig.layout.spacingMedium,
                        child: FloatingActionButton.extended(
                          onPressed: _handlePinGeneration,
                          icon: const Icon(Icons.pin_outlined),
                          label: Text(
                            AppConfig.strings.strategies.getPinButton,
                            style: AppConfig.textStyles.buttonMedium,
                          ),
                          backgroundColor: AppConfig.colors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showTutorial)
          SwipeTutorialOverlay(
            onComplete: _handleTutorialComplete,
          ),
      ],
    );
  }
}
