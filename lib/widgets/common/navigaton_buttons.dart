import 'package:flutter/material.dart';
import '../../blocs/game/game_state.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool showNext;
  final bool showBack;
  final bool enableNext;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;

  const NavigationButtons({
    super.key,
    this.onNext,
    this.onBack,
    this.showNext = true,
    this.showBack = true,
    this.enableNext = true,
    this.iconColor,
    this.iconSize = 56,
    this.padding,
  }) : assert(
          (!showNext || onNext != null) && (!showBack || onBack != null),
          'Callback muss gesetzt sein wenn der entsprechende Button angezeigt wird',
        );

  /// Factory constructor für Game-spezifische Navigation
  factory NavigationButtons.forGameScreen({
    VoidCallback? onNext,
    VoidCallback? onBack,
    required GameScreen currentScreen,
    bool enableNext = true,
  }) {
    return NavigationButtons(
      onNext: currentScreen.canNavigateForward ? onNext : null,
      onBack: currentScreen.canNavigateBack ? onBack : null,
      showNext: currentScreen.canNavigateForward,
      showBack: currentScreen.canNavigateBack,
      enableNext: enableNext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left Navigation Arrow
        if (showBack)
          Positioned(
            left: padding?.left ?? 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: iconColor ?? Colors.white,
                  size: iconSize,
                ),
                onPressed: onBack,
              ),
            ),
          ),

        // Right Navigation Arrow
        if (showNext)
          Positioned(
            right: padding?.right ?? 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: enableNext
                      ? (iconColor ?? Colors.white)
                      : Colors.grey[700],
                  size: iconSize,
                ),
                onPressed: enableNext ? onNext : null,
              ),
            ),
          ),
      ],
    );
  }
}
