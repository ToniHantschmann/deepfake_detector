// Vermutlicher Inhalt von indicators.dart
import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/game/game_bloc.dart';
import '../../../../blocs/game/game_state.dart';
import '../../../../config/app_config.dart';

class AnimationIndicator extends StatelessWidget {
  final bool isManipulated;
  final String normalText;
  final String manipulatedText;

  const AnimationIndicator({
    Key? key,
    required this.isManipulated,
    required this.normalText,
    required this.manipulatedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // BlocBuilder für Sprachänderungen hinzufügen
    return BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) => previous.locale != current.locale,
        builder: (context, _) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConfig.layout.spacingMedium,
              vertical: AppConfig.layout.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: isManipulated
                  ? AppConfig.colors.warning.withOpacity(0.2)
                  : AppConfig.colors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isManipulated ? Icons.warning : Icons.check_circle,
                  color: isManipulated
                      ? AppConfig.colors.warning
                      : AppConfig.colors.secondary,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  isManipulated ? manipulatedText : normalText,
                  style: AppConfig.textStyles.bodySmall.copyWith(
                    color: isManipulated
                        ? AppConfig.colors.warning
                        : AppConfig.colors.secondary,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
