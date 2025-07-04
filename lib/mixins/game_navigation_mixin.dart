import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../constants/overlay_types.dart';

/// Mixin that provides navigation functionality for game screens
/// Can be used by both BaseGameScreen and State classes
mixin GameNavigationMixin {
  /// Navigate back to the previous screen
  void handleBackNavigation(BuildContext context) {
    dispatchGameEvent(context, const PreviousScreen());
  }

  /// Navigate to the next screen
  void handleNextNavigation(BuildContext context) {
    dispatchGameEvent(context, const NextScreen());
  }

  /// Show the login overlay
  void handleLoginNavigation(BuildContext context) {
    dispatchGameEvent(context, const ShowLogin());
  }

  // Restart the game
  void handleRestartGame(BuildContext context) {
    dispatchGameEvent(context, const RestartGame());
  }

  // Quickstart the game
  void handleQuickstartGame(BuildContext context) {
    dispatchGameEvent(context, const QuickStartGame());
  }

  /// Mark a tutorial as completed
  void completeTutorial(BuildContext context, OverlayType tutorialType) {
    dispatchGameEvent(context, OverlayCompleted(tutorialType));
  }

  /// Quit game and show Intro Screen
  void handleEndGame(BuildContext context) {
    dispatchGameEvent(context, const InitializeGame());
  }

  /// Make a deepfake selection with proper timing and navigation
  void makeDeepfakeSelection(BuildContext context, bool isDeepfake) {
    final bloc = context.read<GameBloc>();
    // First set the selection to update UI
    dispatchGameEvent(context, UpdateSelectedVideo(isDeepfake));

    // Short delay to show selection before processing
    Future.delayed(const Duration(milliseconds: 200), () {
      // Record decision first
      bloc.add(MakeDeepfakeDecision(isDeepfake));

      // Wait for state to be updated before navigating
      bloc.stream
          .firstWhere((state) =>
              state.isCorrectGuess != null &&
              state.userGuessIsDeepfake == isDeepfake)
          .then((_) {
        // Now that we're sure the state is updated, navigate
        //bloc.add(MakeDeepfakeDecision(isDeepfake));
        bloc.add(const NextScreen());
      });
    });
  }

  /// Helper method to dispatch events to the GameBloc
  void dispatchGameEvent(BuildContext context, GameEvent event) {
    context.read<GameBloc>().add(event);
  }
}
