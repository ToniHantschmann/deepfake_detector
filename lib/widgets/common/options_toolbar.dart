import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/window_manager.dart';

class OptionsToolbar extends StatefulWidget {
  const OptionsToolbar({Key? key}) : super(key: key);

  @override
  State<OptionsToolbar> createState() => _OptionsToolbarState();
}

class _OptionsToolbarState extends State<OptionsToolbar> {
  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to rebuild when window manager state changes
    return AnimatedBuilder(
      animation: WindowManager.instance,
      builder: (context, child) {
        // Toolbar nur anzeigen, wenn wir nicht im Vollbildmodus sind
        if (WindowManager.instance.isFullScreen) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 48,
          color: const Color(0xFF171717),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Export-Button
              _buildToolbarButton(
                icon: Icons.download,
                label: 'Statistikdaten exportieren',
                onPressed: () {
                  // Export-Funktion implementieren
                },
              ),

              const SizedBox(width: 8),

              // Vollbild-Button
              _buildToolbarButton(
                icon: Icons.fullscreen,
                label: 'Vollbildmodus (F11)',
                onPressed: () {
                  WindowManager.instance.toggleFullScreen();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: label,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label.split(' ')[0]), // Zeige nur das erste Wort an
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _exportStatistics() async {}
}
