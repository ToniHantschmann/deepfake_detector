import 'package:flutter/material.dart';
import '../../blocs/game/game_state.dart';

class ProgressBar extends StatelessWidget {
  final GameScreen currentScreen;

  const ProgressBar({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  // Check if a screen is completed (all previous screens are done)
  bool _isScreenCompleted(GameScreen screen) {
    // Introduction, login and register screens don't count for progress
    if (screen == GameScreen.introduction ||
        screen == GameScreen.login ||
        screen == GameScreen.register) {
      return false;
    }
    return currentScreen.index > screen.index;
  }

  // Check if this is the currently active screen
  bool _isScreenActive(GameScreen screen) {
    return currentScreen == screen;
  }

  // Get the display label for each screen
  String _getScreenLabel(GameScreen screen) {
    switch (screen) {
      case GameScreen.firstVideo:
        return 'Video 1';
      case GameScreen.secondVideo:
        return 'Video 2';
      case GameScreen.comparison:
        return 'Comparison';
      case GameScreen.result:
        return 'Feedback';
      case GameScreen.statistics:
        return 'Strategies';
      default:
        return '';
    }
  }

  // List of screens to show in the progress bar
  List<GameScreen> get _progressScreens => [
        GameScreen.firstVideo,
        GameScreen.secondVideo,
        GameScreen.comparison,
        GameScreen.result,
        GameScreen.statistics,
      ];

  @override
  Widget build(BuildContext context) {
    // Hide progress bar for intro/auth screens
    if (currentScreen == GameScreen.introduction ||
        currentScreen == GameScreen.login ||
        currentScreen == GameScreen.register) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 56,
      color: const Color(0xCC212121),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: _progressScreens.asMap().entries.map((entry) {
            final index = entry.key;
            final screen = entry.value;
            final isLast = index == _progressScreens.length - 1;

            return _buildProgressItem(
              screen: screen,
              number: index + 1,
              isActive: _isScreenActive(screen),
              isCompleted: _isScreenCompleted(screen),
              showConnector: !isLast,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required GameScreen screen,
    required int number,
    required bool isActive,
    required bool isCompleted,
    required bool showConnector,
  }) {
    return Expanded(
      child: Row(
        children: [
          // Circle with number or checkmark
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCompleted
                  ? Colors.blue
                  : const Color(0xFF404040),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Screen label
          Text(
            _getScreenLabel(screen),
            style: TextStyle(
              color: isActive || isCompleted ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
          // Connector line between items
          if (showConnector) ...[
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: isCompleted ? Colors.blue : const Color(0xFF404040),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
