import 'package:deepfake_detector/repositories/internal_statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../utils/window_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class OptionsToolbar extends StatefulWidget {
  const OptionsToolbar({Key? key}) : super(key: key);

  @override
  State<OptionsToolbar> createState() => _OptionsToolbarState();
}

class _OptionsToolbarState extends State<OptionsToolbar> {
  bool _isExporting = false;
  String? _exportResult;

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder verwenden, um neu zu bauen, wenn sich der Window-Manager-Status ändert
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
              const Spacer(),

              // Statusmeldung für Export
              if (_exportResult != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _exportResult!,
                      style: TextStyle(
                        color: _exportResult!.startsWith('Fehler')
                            ? AppConfig.colors.error
                            : AppConfig.colors.success,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // Export-Button
              _buildToolbarButton(
                icon: Icons.download,
                label: 'Statistikdaten exportieren',
                onPressed: _isExporting ? null : _exportStatistics,
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
    required VoidCallback? onPressed,
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

  Future<void> _exportStatistics() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _exportResult = null;
    });

    try {
      // Exportiere die Statistikdaten in eine JSON-Datei
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final exportPath = path.join(directory.path, 'deepfake_stats');

      // Stelle sicher, dass das Exportverzeichnis existiert
      final exportDir = Directory(exportPath);
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final filePath = path.join(exportPath, 'deepfake_stats_$timestamp.json');

      // Interne Statistiken vom Repository holen
      final internalStatsRepo = InternalStatisticsRepository();
      final stats = await internalStatsRepo.getStatistics();

      // Statistik zusammenfassen als zusätzliche Textdatei
      final summaryPath =
          path.join(exportPath, 'deepfake_stats_summary_$timestamp.txt');
      final summary = await internalStatsRepo.getStatisticsSummary();
      final summaryFile = File(summaryPath);
      await summaryFile.writeAsString(summary);

      // Statistiken in JSON konvertieren und in Datei schreiben
      final jsonFile = File(filePath);
      await jsonFile.writeAsString(json.encode(stats.toJson()));

      setState(() {
        _exportResult = 'Exportiert nach: $exportPath';
      });

      // Kopiere Pfad in die Zwischenablage
      await Clipboard.setData(ClipboardData(text: exportPath));
      setState(() {
        _exportResult = 'Exportiert und Pfad kopiert';
      });

      // Optional: Öffne den Ordner mit der exportierten Datei
      if (Platform.isWindows) {
        try {
          Process.run('explorer.exe', [exportPath]);
        } catch (e) {
          debugPrint('Fehler beim Öffnen des Explorers: $e');
        }
      }
    } catch (e) {
      setState(() {
        _exportResult = 'Fehler beim Exportieren: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });

      // Blende die Erfolgsmeldung nach einiger Zeit aus
      if (_exportResult != null && !_exportResult!.startsWith('Fehler')) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _exportResult = null;
            });
          }
        });
      }
    }
  }
}
