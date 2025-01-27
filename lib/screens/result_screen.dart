import 'package:flutter/material.dart';
import '../models/video_model.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';

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
    if (state.status == GameStatus.loading ||
        state.selectedVideoIndex == null ||
        state.isCorrectGuess == null ||
        state.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF171717),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedVideo = state.videos[state.selectedVideoIndex!];

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Column(
        children: [
          // Progress Bar
          ProgressBar(currentScreen: state.currentScreen),

          // Main Content Area - Scrollable
          Expanded(
            child: Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultHeader(state.isCorrectGuess!),
                        const SizedBox(height: 32),
                        _buildDeepfakeExplanation(selectedVideo),
                        // Add bottom padding to ensure content doesn't get hidden behind statistics
                        const SizedBox(height: 180),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons
                NavigationButtons.forGameScreen(
                  onNext: () => handleNextNavigation(context),
                  currentScreen: GameScreen.result,
                ),

                // Statistics Panel - Fixed at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildStatistics(state),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    final currentRunStats = state.userStatistics!.recentAttempts
        .where((attempt) => attempt.wasCorrect)
        .length;
    final totalRunAttempts = state.userStatistics!.recentAttempts.length;
    final totalCorrect = state.userStatistics!.correctGuesses;
    final totalAttempts = state.userStatistics!.totalAttempts;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
