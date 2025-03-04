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
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) => previous.locale != current.locale,
      builder: (context, state) {
        // Determine which button to show based on current locale
        return _buildSingleLanguageButton(context, state);
      },
    );
  }

  Widget _buildSingleLanguageButton(BuildContext context, GameState state) {
    // If current locale is English, show only the German button and vice versa
    final oppositeLocale =
        state.locale == AppLocale.en ? AppLocale.de : AppLocale.en;
    final buttonLabel = oppositeLocale == AppLocale.en ? 'EN' : 'DE';

    return ElevatedButton(
      onPressed: () {
        final gameBloc = context.read<GameBloc>();
        gameBloc.add(ChangeLanguage(oppositeLocale));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.colors.primary,
        minimumSize: const Size(48, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 4, // Leichter Schatten für bessere Sichtbarkeit
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide.none, // Kein Rahmen
        ),
      ),
      child: Text(
        buttonLabel,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
