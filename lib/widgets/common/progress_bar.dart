// lib/widgets/common/progress_bar.dart

import 'package:flutter/material.dart';
import '../../blocs/game/game_state.dart';

class ProgressBar extends StatelessWidget {
  final GameScreen currentScreen;

  const ProgressBar({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  bool _isScreenCompleted(GameScreen screen) {
    // Introduction und Login Screens zählen nicht zum Progress
    if (screen == GameScreen.introduction ||
        screen == GameScreen.login ||
        screen == GameScreen.register) {
      return false;
    }
    return currentScreen.index >= screen.index;
  }

  bool _isScreenActive(GameScreen screen) {
    return currentScreen == screen;
  }

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

  // Gibt nur die Screens zurück, die im Progress angezeigt werden sollen
  List<GameScreen> get _progressScreens => [
        GameScreen.firstVideo,
        GameScreen.secondVideo,
        GameScreen.comparison,
        GameScreen.result,
        GameScreen.statistics,
      ];

  @override
  Widget build(BuildContext context) {
    // Zeige keine Progress Bar für bestimmte Screens
    if (currentScreen == GameScreen.introduction ||
        currentScreen == GameScreen.login ||
        currentScreen == GameScreen.register) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 56,
      color: const Color(0xFF171717),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: _progressScreens.map((screen) {
            final isLast = screen == _progressScreens.last;
            return _buildProgressItem(
              label: _getScreenLabel(screen),
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
    required String label,
    required bool isActive,
    required bool isCompleted,
    required bool showConnector,
  }) {
    return Expanded(
      child: Row(
        children: [
          // Circle with Number or Checkmark
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
                      '${_progressScreens.indexOf(_progressScreens.firstWhere((s) => s.index == currentScreen.index)) + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Label
          Text(
            label,
            style: TextStyle(
              color: isActive || isCompleted ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
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
