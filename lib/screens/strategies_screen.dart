import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/constants/overlay_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../models/strategy_model.dart';
import '../widgets/detection_strategies/strategy_carousel/strategy_carousel.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/tutorial/swipe_tutorial.dart';
import '../config/app_config.dart';
import 'base_game_screen.dart';
import '../widgets/overlays/pin_overlay.dart';

class StrategiesScreen extends BaseGameScreen {
  const StrategiesScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.currentPin != current.currentPin ||
        previous.generatedPin != current.generatedPin ||
        previous.currentStrategyIndex != current.currentStrategyIndex ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    return _StrategiesScreenContent(
      state: state,
    );
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
        !widget.state.hasOverlayBeenShown(OverlayType.strategySwipe) &&
        widget.state.userStatistics!.totalAttempts == 1;
  }

  void _handleTutorialComplete() {
    setState(() {
      _showTutorial = false;
    });
    context
        .read<GameBloc>()
        .add(const OverlayCompleted(OverlayType.strategySwipe));
  }

  void _handleRestartGame() {
    context.read<GameBloc>().add(const RestartGame());
  }

  void _handleShowStatistics() {
    context.read<GameBloc>().add(const NextScreen());
  }

  void _handleBackNavigation() {
    context.read<GameBloc>().add(const PreviousScreen());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).strategies;
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
                                    strings.title,
                                    style: AppConfig.textStyles.h2,
                                  ),
                                  SizedBox(
                                      height: AppConfig.layout.spacingSmall),
                                  Text(
                                    strings.subtitle,
                                    style:
                                        AppConfig.textStyles.bodyLarge.copyWith(
                                      color: AppConfig.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Carousel
                            Expanded(
                              child: StrategyCarousel(
                                strategies: getImplementedStrategies(context),
                                onPageChanged:
                                    (index, strategyId, previousStrategyId) {
                                  context.read<GameBloc>().add(
                                        StrategyIndexChanged(
                                          newIndex: index,
                                          strategyId: strategyId,
                                          previousStrategyId:
                                              previousStrategyId,
                                        ),
                                      );
                                },
                                viewedStrategyIds: widget.state
                                    .viewedStrategyIds, // Pass the viewed strategies set
                              ),
                            ),
                            // Buttons Container
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    AppConfig.layout.screenPaddingHorizontal,
                                vertical: AppConfig.layout.spacingLarge,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildActionButton(
                                    onPressed: _handleRestartGame,
                                    text: strings.nextGameButton,
                                    icon: Icons.play_arrow,
                                    color: AppConfig.colors.primary,
                                  ),
                                  SizedBox(
                                      width: AppConfig.layout.spacingXLarge),
                                  _buildActionButton(
                                    onPressed: _handleShowStatistics,
                                    text: strings.statsButton,
                                    icon: Icons.bar_chart,
                                    color: AppConfig.colors.secondary,
                                  ),
                                ],
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
}
