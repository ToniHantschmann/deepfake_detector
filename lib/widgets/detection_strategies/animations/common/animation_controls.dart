import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/game/game_bloc.dart';
import '../../../../blocs/game/game_state.dart';
import '../../../../config/app_config.dart';

class AnimationControls extends StatelessWidget {
  final bool isManipulated;
  final ValueChanged<bool> onModeChanged;

  const AnimationControls({
    Key? key,
    required this.isManipulated,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fügen Sie einen BlocBuilder hinzu, um auf Sprachänderungen zu reagieren
    return BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) => previous.locale != current.locale,
        builder: (context, state) {
          final strings =
              AppConfig.getStrings(context.currentLocale).strategyCard;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(
                strings.toggleOriginal,
                false,
                context,
              ),
              SizedBox(width: AppConfig.layout.spacingMedium),
              _buildModeButton(
                strings.toggleManipulated,
                true,
                context,
              ),
            ],
          );
        });
  }

  Widget _buildModeButton(
      String label, bool manipulated, BuildContext context) {
    final isSelected = isManipulated == manipulated;
    return TextButton(
      onPressed: () => onModeChanged(manipulated),
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? AppConfig.colors.primary : AppConfig.colors.background,
        padding: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.spacingLarge,
          vertical: AppConfig.layout.spacingMedium,
        ),
      ),
      child: Text(
        label,
        style: AppConfig.textStyles.buttonMedium.copyWith(
          color: isSelected
              ? AppConfig.colors.textPrimary
              : AppConfig.colors.textSecondary,
        ),
      ),
    );
  }
}
