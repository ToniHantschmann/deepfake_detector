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
        return _buildLanguageButton(context, state);
      },
    );
  }

  Widget _buildLanguageButton(BuildContext context, GameState state) {
    // If current locale is English, show only the German button and vice versa
    final oppositeLocale =
        state.locale == AppLocale.en ? AppLocale.de : AppLocale.en;
    final buttonLabel = oppositeLocale == AppLocale.en ? 'EN' : 'DE';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          final gameBloc = context.read<GameBloc>();
          gameBloc.add(ChangeLanguage(oppositeLocale));
        },
        icon: const Icon(
          Icons.language,
          size: 24, // Increased icon size from 18 to 24
          color: Colors.white,
        ),
        label: Text(
          buttonLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16, // Increased text size
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(90, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}
