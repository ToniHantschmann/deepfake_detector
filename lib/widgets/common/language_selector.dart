// lib/widgets/common/language_selector.dart
import 'package:flutter/material.dart';
import 'package:deepfake_detector/config/config.dart';
import 'package:deepfake_detector/config/localization/app_locale.dart';
import 'package:deepfake_detector/blocs/game/game_language_extension.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.currentLocale;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLocale.values.map((locale) {
          final isSelected = locale == currentLocale;
          final label = locale == AppLocale.en ? 'EN' : 'DE';

          return GestureDetector(
            onTap: () => context.changeLanguage(locale),
            child: Container(
              width: 48.0,
              height: 36.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConfig.colors.primary
                    : AppConfig.colors.backgroundDark,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppConfig.colors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
