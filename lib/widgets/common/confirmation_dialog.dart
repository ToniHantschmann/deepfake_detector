import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Ein wiederverwendbarer Bestätigungsdialog im App-Design-Stil
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final IconData? confirmIcon;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.cancelText = 'Abbrechen',
    this.confirmText = 'Bestätigen',
    this.confirmColor,
    this.confirmIcon,
  }) : super(key: key);

  /// Hilfsmethode zum Anzeigen des Dialogs
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Abbrechen',
    String confirmText = 'Bestätigen',
    Color? confirmColor,
    IconData? confirmIcon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        confirmIcon: confirmIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppConfig.textStyles.overlayTitle,
      ),
      backgroundColor: AppConfig.colors.backgroundLight,
      content: Text(
        message,
        style: AppConfig.textStyles.bodyMedium,
      ),
      actions: [
        // Abbrechen-Button
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: AppConfig.colors.textSecondary),
          ),
        ),

        // Bestätigungs-Button
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: Icon(confirmIcon ?? Icons.check),
          label: Text(confirmText),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppConfig.colors.primary,
          ),
        ),
      ],
    );
  }
}
