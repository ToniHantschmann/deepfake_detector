import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';

class ResultScreen extends BaseGameScreen {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.isCorrectGuess != current.isCorrectGuess;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    if (state.selectedVideoIndex == null ||
        state.isCorrectGuess == null ||
        state.videos.isEmpty) {
      return const Center(child: Text('Error: No result data available'));
    }

    final selectedVideo = state.videos[state.selectedVideoIndex!];

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Stack(
          children: [
            // Progress Bar Placeholder
            Container(
              width: double.infinity,
              height: 8,
              color: Colors.grey[800],
            ),

            // Main Content
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 120.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(state.isCorrectGuess!),
                  const SizedBox(height: 32),
                  _buildDeepfakeExplanation(selectedVideo),
                  const SizedBox(height: 32),
                  _buildStatistics(state),
                ],
              ),
            ),

            // Navigation Buttons - neue Implementierung
            NavigationButtons.forGameScreen(
              onNext: () => handleNextNavigation(context),
              onBack: () => handleBackNavigation(context),
              currentScreen: GameScreen.result,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(bool isCorrect) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Text(
            isCorrect ? 'Correct decision!' : 'Wrong decision!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepfakeExplanation(Video selectedVideo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why this was a deepfake:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...selectedVideo.deepfakeIndicators.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final indicator = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Reason $index: $indicator',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(GameState state) {
    if (state.userStatistics == null) {
      return const SizedBox.shrink();
    }

    // Berechne die Statistiken für den aktuellen Run
    final currentRunStats = state.userStatistics!.recentAttempts
        .where((attempt) => attempt.wasCorrect)
        .length;
    final totalRunAttempts = state.userStatistics!.recentAttempts.length;

    // Gesamtstatistiken
    final totalCorrect = state.userStatistics!.correctGuesses;
    final totalAttempts = state.userStatistics!.totalAttempts;

    return Row(
      children: [
        // Current Run Statistics
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Current Run',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentRunStats of $totalRunAttempts correct',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Overall Statistics
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Overall Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalCorrect of $totalAttempts correct',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
