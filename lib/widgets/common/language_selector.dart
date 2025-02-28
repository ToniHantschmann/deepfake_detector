// lib/widgets/common/language_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deepfake_detector/config/app_config.dart';
import 'package:deepfake_detector/config/localization/app_locale.dart';
import 'package:deepfake_detector/blocs/game/game_bloc.dart';
import 'package:deepfake_detector/blocs/game/game_state.dart';
import 'package:deepfake_detector/blocs/game/game_event.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Always rebuild the widget tree for language changes
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (previous, current) => previous.locale != current.locale,
      listener: (context, state) {},
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageButton(context, AppLocale.de, state),
            const SizedBox(width: 8),
            _buildLanguageButton(context, AppLocale.en, state),
          ],
        );
      },
    );
  }

  Widget _buildLanguageButton(
      BuildContext context, AppLocale locale, GameState state) {
    final isSelected = locale == state.locale;
    final label = locale == AppLocale.en ? 'EN' : 'DE';

    return ElevatedButton(
      onPressed: () {
        // Try an approach that doesn't use BlocBuilder
        final gameBloc = context.read<GameBloc>();
        gameBloc.add(ChangeLanguage(locale));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppConfig.colors.primary
            : AppConfig.colors.backgroundDark,
        minimumSize: const Size(48, 36),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppConfig.colors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
