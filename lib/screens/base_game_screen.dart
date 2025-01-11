import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';

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

        return buildGameScreen(context, state);
      },
    );
  }

  /// Override this to build the main screen content
  Widget buildGameScreen(BuildContext context, GameState state);

  /// Override this to customize when the screen should rebuild
  bool shouldRebuild(GameState previous, GameState current) => true;

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
}
