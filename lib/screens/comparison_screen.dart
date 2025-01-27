import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import 'base_game_screen.dart';

class ComparisonScreen extends BaseGameScreen {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.selectedVideoIndex != current.selectedVideoIndex;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    if (state.status == GameStatus.loading || state.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              ProgressBar(currentScreen: state.currentScreen),
              Expanded(
                child: Stack(
                  children: [
                    // Main Content Column
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 120.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Which video is the Deepfake?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select the video you think is artificially generated',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: _buildVideoComparison(context, state),
                          ),
                          // Confirm Button Container (immer sichtbar)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24.0,
                              horizontal: 32.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52, // Feste Höhe für konsistentes Layout
                              child: state.selectedVideoIndex != null
                                  ? ElevatedButton(
                                      onPressed: () {
                                        // Dispatch SelectDeepfake only when confirming
                                        dispatchGameEvent(
                                          context,
                                          SelectDeepfake(
                                              state.selectedVideoIndex!),
                                        );
                                        handleNextNavigation(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Confirm Selection',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : null, // Kein Button, aber Platz wird reserviert
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation Buttons
                    NavigationButtons.forGameScreen(
                      onNext: () {
                        dispatchGameEvent(
                            context, SelectDeepfake(state.selectedVideoIndex!));
                        handleNextNavigation(context);
                      },
                      onBack: () => handleBackNavigation(context),
                      currentScreen: GameScreen.comparison,
                      enableNext: state.selectedVideoIndex != null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildVideoComparison(BuildContext context, GameState state) {
    return Row(
      children: [
        // First Video
        Expanded(
          child: _buildVideoCard(
              context: context,
              video: state.videos[0],
              isSelected: state.selectedVideoIndex == 0,
              onSelect: () => _handleVideoSelection(context, 0)),
        ),
        const SizedBox(width: 24),
        // Second Video
        Expanded(
          child: _buildVideoCard(
              context: context,
              video: state.videos[1],
              isSelected: state.selectedVideoIndex == 1,
              onSelect: () => _handleVideoSelection(context, 1)),
        ),
      ],
    );
  }

  void _handleVideoSelection(BuildContext context, int index) {
    // Update the state locally without dispatching SelectDeepfake
    dispatchGameEvent(context, UpdateSelectedVideo(index));
  }

  Widget _buildVideoCard({
    required BuildContext context,
    required Video video,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail Container mit festem 16:9 Verhältnis
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                video.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'This is the Deepfake',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
}
