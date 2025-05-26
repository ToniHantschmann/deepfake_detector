import 'package:deepfake_detector/mixins/game_navigation_mixin.dart';
import 'package:deepfake_detector/screens/qr_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';
import '../constants/overlay_types.dart';
import '../widgets/common/swipe_navigation_wrapper.dart';

/// Base class for all game screens
/// Provides common functionality and ensures consistent behavior
abstract class BaseGameScreen extends StatelessWidget with GameNavigationMixin {
  const BaseGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: shouldRebuild,
      builder: (context, state) {
        if (state.status == GameStatus.loading) {
          return _buildLoadingScreen();
        }

        if (state.status == GameStatus.error) {
          return _buildErrorScreen(context, state.errorMessage);
        }

        // Wrap the screen content with swipe navigation
        return _wrapWithSwipeNavigation(context, state);
      },
    );
  }

  /// Wraps the screen content with swipe gesture detection
  Widget _wrapWithSwipeNavigation(BuildContext context, GameState state) {
    return SwipeNavigationWrapper(
      currentScreen: state.currentScreen,
      onNext: state.currentScreen.canNavigateForward
          ? () => handleNextNavigation(context)
          : null,
      onBack: state.currentScreen.canNavigateBack
          ? () => handleBackNavigation(context)
          : null,
      enableNext: state.currentScreen.canNavigateForward,
      child: buildGameScreen(context, state),
    );
  }

  /// Determine if navigation to the next screen is allowed based on the current state
  bool _canNavigateToNextScreen(GameState state) {
    // Check current screen to determine specific conditions
    switch (state.currentScreen) {
      case GameScreen.decision:
        // For decision screen, we need a selected video
        return state.userGuessIsDeepfake != null;
      case GameScreen.result:
        // For result screen we always allow forward navigation
        return true;
      case GameScreen.firstVideo:
        // For video screens we can navigate forward unconditionally
        return true;
      default:
        return true;
    }
  }

  /// Override this to build the main screen content
  Widget buildGameScreen(BuildContext context, GameState state) {
    throw UnimplementedError('Subclasses must override buildGameScreen');
  }

  /// Override this to customize when the screen should rebuild
  bool shouldRebuild(GameState previous, GameState current) {
    // Always check for these common state changes including locale
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.locale != current.locale;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String? message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? 'An error occurred',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<GameBloc>().add(const RestartGame()),
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
