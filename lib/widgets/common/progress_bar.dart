import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import '../../blocs/game/game_state.dart';
import '../../config/app_config.dart';

class ProgressBar extends StatelessWidget {
  final GameScreen currentScreen;

  const ProgressBar({
    Key? key,
    required this.currentScreen,
  }) : super(key: key);

  bool _isScreenCompleted(GameScreen screen) {
    if (screen == GameScreen.introduction || screen == GameScreen.login) {
      return false;
    }
    return currentScreen.index > screen.index;
  }

  bool _isScreenActive(GameScreen screen) {
    return currentScreen == screen;
  }

  String _getScreenLabel(GameScreen screen, ProgressBarStrings strings) {
    switch (screen) {
      case GameScreen.firstVideo:
        return strings.firstVideo;
      case GameScreen.secondVideo:
        return strings.secondVideo;
      case GameScreen.comparison:
        return strings.comparison;
      case GameScreen.result:
        return strings.feedback;
      case GameScreen.statistics:
        return strings.strategies;
      default:
        return '';
    }
  }

  List<GameScreen> get _progressScreens => [
        GameScreen.firstVideo,
        GameScreen.secondVideo,
        GameScreen.comparison,
        GameScreen.result,
        GameScreen.statistics,
      ];

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).progressBar;
    if (currentScreen == GameScreen.introduction ||
        currentScreen == GameScreen.login) {
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
              strings: strings,
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
    required ProgressBarStrings strings,
  }) {
    return Expanded(
      child: Row(
        children: [
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
          Text(
            _getScreenLabel(screen, strings),
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
