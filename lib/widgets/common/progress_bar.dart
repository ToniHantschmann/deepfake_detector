import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:deepfake_detector/widgets/common/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
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
      case GameScreen.decision:
        return strings.decision;
      case GameScreen.result:
        return strings.result;
      case GameScreen.strategy:
        return strings.strategies;
      case GameScreen.statistics:
        return strings.statistics;
      default:
        return '';
    }
  }

  List<GameScreen> get _progressScreens => [
        GameScreen.firstVideo,
        GameScreen.decision,
        GameScreen.result,
        GameScreen.strategy,
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
      height: 64.0, // Leicht erhöhte Höhe
      color: const Color(0xCC212121), // Original Farbe beibehalten
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Navigationsschritte
            Expanded(
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

            // Language Selector rechts positioniert
            const LanguageSelector(),

            // Abstand zwischen Language Selector und Schließen-Button
            SizedBox(width: 16.0),

            // Schließen-Button
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                // InitializeGame Event auslösen
                context.read<GameBloc>().add(const InitializeGame());
              },
            ),
          ],
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
            width: 32, // Größerer Kreis
            height: 32, // Größerer Kreis
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCompleted
                  ? Colors.blue // Original Farbe beibehalten
                  : const Color(0xFF404040), // Original Farbe beibehalten
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    )
                  : Text(
                      number.toString(),
                      style: AppConfig.textStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getScreenLabel(screen, strings),
            style: AppConfig.textStyles.bodyMedium.copyWith(
              color: isActive || isCompleted ? Colors.white : Colors.grey,
              fontSize: 20,
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
