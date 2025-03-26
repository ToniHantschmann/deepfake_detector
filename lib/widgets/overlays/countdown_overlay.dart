// lib/widgets/common/countdown_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_state.dart';
import '../../blocs/game/game_language_extension.dart';
import '../../config/app_config.dart';

/// Ein vereinfachtes Overlay, das angezeigt wird, wenn die App wegen Inaktivität zurückgesetzt wird
class CountdownOverlay extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onContinue;

  const CountdownOverlay({
    Key? key,
    required this.secondsRemaining,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).inactivity;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 450,
              minWidth: 320,
            ),
            child: Material(
              color: Colors.grey[850], // Dunkler Hintergrund
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Countdown-Kreis oben
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          '$secondsRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Titel
                    Text(
                      strings.inactivityTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Beschreibung
                    Text(
                      strings.inactivityMessage
                          .replaceAll('{seconds}', '$secondsRemaining'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Weiter-Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          strings.continueButton,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
