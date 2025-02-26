import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/localization/app_locale.dart';
import 'game_bloc.dart';
import 'game_event.dart';

extension GameLanguageExtension on BuildContext {
  // Aktuelle Sprache aus dem GameState abrufen
  AppLocale get currentLocale => read<GameBloc>().state.locale;

  // Sprache ändern
  void changeLanguage(AppLocale locale) {
    read<GameBloc>().add(ChangeLanguage(locale));
  }
}
