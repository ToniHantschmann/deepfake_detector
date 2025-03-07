// Modified base_game_screen.dart with language selector in bottom left

import 'package:deepfake_detector/widgets/common/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';
import '../widgets/common/swipe_navigation_wrapper.dart';

/// Base class for all game screens
/// Provides common functionality and ensures consistent behavior
abstract class BaseGameScreen extends StatelessWidget {
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

        // Wrap the screen content with both the swipe navigation and the language selector
        return _wrapWithLanguageSelector(
            _wrapWithSwipeNavigation(context, state));
      },
    );
  }

  /// Adds the language selector to the bottom left of the screen
  Widget _wrapWithLanguageSelector(Widget child) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.currentScreen != current.currentScreen,
      builder: (context, state) {
        return Stack(
          children: [
            child,
            // Position the language selector in the bottom left
            const Positioned(
              left: 16,
              bottom: 16,
              child: LanguageSelector(),
            ),
          ],
        );
      },
    );
  }

  /// Wraps the screen content with swipe gesture detection
  Widget _wrapWithSwipeNavigation(BuildContext context, GameState state) {
    return SwipeNavigationWrapper(
      currentScreen: state.currentScreen,
      onNext: state.currentScreen.canNavigateForward
          ? () {
              final bool canProceed = _canNavigateToNextScreen(state);
              if (canProceed) {
                // Special handling for comparison screen
                if (state.currentScreen == GameScreen.comparison &&
                    state.selectedVideoIndex != null) {
                  // Capture the GameBloc instance before using it with Future.delayed
                  final gameBloc = context.read<GameBloc>();
                  // First record the selection
                  gameBloc.add(SelectDeepfake(state.selectedVideoIndex!));
                  // Then navigate using the captured bloc instance
                  gameBloc.add(const NextScreen());
                } else {
                  // Normal navigation for other screens
                  handleNextNavigation(context);
                }
              }
            }
          : null,
      onBack: state.currentScreen.canNavigateBack
          ? () => handleBackNavigation(context)
          : null,
      enableNext: _canNavigateToNextScreen(state),
      child: buildGameScreen(context, state),
    );
  }

  /// Determine if navigation to the next screen is allowed based on the current state
  bool _canNavigateToNextScreen(GameState state) {
    // Check current screen to determine specific conditions
    switch (state.currentScreen) {
      case GameScreen.comparison:
        // For comparison screen, we need a selected video
        return state.selectedVideoIndex != null;
      case GameScreen.result:
        // For result screen we always allow forward navigation
        return true;
      case GameScreen.firstVideo:
      case GameScreen.secondVideo:
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

  /// Helper method to dispatch events to the GameBloc
  void dispatchGameEvent(BuildContext context, GameEvent event) {
    context.read<GameBloc>().add(event);
  }

  /// Helper methods for navigation
  void handleBackNavigation(BuildContext context) {
    dispatchGameEvent(context, const PreviousScreen());
  }

  void handleNextNavigation(BuildContext context) {
    dispatchGameEvent(context, const NextScreen());
  }

  void handleLoginNavigation(BuildContext context) {
    dispatchGameEvent(context, const ShowLogin());
  }
}
