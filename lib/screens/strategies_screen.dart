import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/auth/generated_pin_display.dart';
import 'base_game_screen.dart';
import '../widgets/detection_strategies/strategy_card.dart';
import '../widgets/detection_strategies/blinking_animation.dart';
import '../widgets/detection_strategies/skin_texture_animation.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
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
    if (state.generatedPin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.8),
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
      backgroundColor: const Color(0xFF171717),
      body: Column(
        children: [
          ProgressBar(currentScreen: state.currentScreen),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to detect Deepfakes?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Learn the key strategies to identify deepfake videos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildStrategiesGrid(context),
                        const SizedBox(height: 24),
                        _buildTipCard(),
                        const SizedBox(height: 48),
                        _buildNextButton(context),
                        const SizedBox(height: 32),
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
        return constraints.maxWidth > 800
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBlinkingStrategy()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildSkinTextureStrategy()),
                ],
              )
            : Column(
                children: [
                  _buildBlinkingStrategy(),
                  const SizedBox(height: 24),
                  _buildSkinTextureStrategy(),
                ],
              );
      },
    );
  }

  Widget _buildBlinkingStrategy() {
    return const StrategyCard(
      title: 'Natural Blinking',
      description: 'Humans typically blink every 4-6 seconds. '
          'In deepfakes, blinking patterns are often unnatural or missing completely.',
      child: BlinkingAnimation(),
    );
  }

  Widget _buildSkinTextureStrategy() {
    return const StrategyCard(
      title: 'Skin Texture Analysis',
      description:
          'Look for inconsistencies in skin texture. Deepfakes might show '
          'unnatural smoothness or aging patterns that don\'t match between '
          'different facial features.',
      child: SkinTextureAnimation(),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.yellow[600],
            size: 24,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Tip: Focus on these features in your next attempt. '
              'The more you practice, the better you\'ll become at detecting deepfakes!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
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
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Text(
            'Next Game',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton.extended(
        onPressed: () => context.read<GameBloc>().add(const GeneratePin()),
        icon: const Icon(Icons.pin_outlined),
        label: const Text(
          'Get PIN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
