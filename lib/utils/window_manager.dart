// lib/utils/window_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:deepfake_detector/models/internal_statistics_model.dart';
import 'package:deepfake_detector/repositories/internal_statistics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart' as wm;

class WindowManager extends ChangeNotifier {
  static final WindowManager _instance = WindowManager._internal();
  static WindowManager get instance => _instance;
  WindowManager._internal();

  bool _isFullScreen = true;
  bool get isFullScreen => _isFullScreen;

  // Initialisierung der Fenstergröße
  Future<void> initWindow() async {
    if (Platform.isWindows) {
      // Fenstermanager initialisieren
      await wm.windowManager.ensureInitialized();

      // Fensteroptionen setzen
      const windowOptions = wm.WindowOptions(
        size: Size(1024, 768),
        minimumSize: Size(1024, 768),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: wm.TitleBarStyle.hidden,
      );

      await wm.windowManager.waitUntilReadyToShow(windowOptions, () async {
        await wm.windowManager.show();
        await wm.windowManager.focus();
        await wm.windowManager.setTitle('Deepfake Detector');

        // Starte im Vollbildmodus
        await toggleFullScreen(true);
      });
    }
  }

  // Umschalter für Vollbildmodus
  Future<void> toggleFullScreen([bool? forcedState]) async {
    if (!Platform.isWindows) return;

    _isFullScreen = forcedState ?? !_isFullScreen;

    if (_isFullScreen) {
      // Vollbild aktivieren
      await wm.windowManager.setFullScreen(true);
      await wm.windowManager.setTitleBarStyle(wm.TitleBarStyle.hidden);
    } else {
      // Normalen Fenstermodus wiederherstellen
      await wm.windowManager.setFullScreen(false);
      await wm.windowManager.setTitleBarStyle(wm.TitleBarStyle.normal);

      // Zentriere das Fenster und setze eine vernünftige Größe
      await wm.windowManager.setSize(const Size(1200, 800));
      await wm.windowManager.center();
    }
    // Notify listeners about the state change
    notifyListeners();
  }

  // Exportieren der Statistikdaten
  Future<String> exportStatistics() async {
    try {
      final repository = InternalStatisticsRepository();
      final statistics = await repository.getStatistics();

      // Erstelle Dateinamen mit Timestamp
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final filename = 'deepfake_stats_$timestamp.json';

      // Speichere in den Dokumente-Ordner
      final documentsDir = await getApplicationDocumentsDirectory();
      final statsDir = Directory('${documentsDir.path}/DeepfakeDetector/stats');

      // Erstelle Verzeichnis falls es nicht existiert
      if (!await statsDir.exists()) {
        await statsDir.create(recursive: true);
      }

      // Schreibe JSON-Datei
      final file = File('${statsDir.path}/$filename');
      await file.writeAsString(statsToJson(statistics));

      return file.path;
    } catch (e) {
      return 'Fehler beim Exportieren: $e';
    }
  }

  // Hilfsmethode zur JSON-Formatierung der Statistikdaten
  String statsToJson(InternalStatistics statistics) {
    final Map<String, dynamic> formattedStats = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalPlayers': statistics.players.length,
      'totalGamesPlayed': statistics.totalGamesPlayed,
      'averageSuccessRate': statistics.averageSuccessRate,
      'playersWithPin': statistics.playersWithPin,
      'returnedPlayers': statistics.returnedPlayers,
      'firstTimeQuitters': statistics.firstTimeQuitters,
      'players': statistics.players.map((player) => player.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(formattedStats);
  }
}

// Tastatursteuerung für Vollbildmodus und andere Tastenkürzel
class AppShortcutManager extends StatelessWidget {
  final Widget child;

  const AppShortcutManager({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.f11) {
            WindowManager.instance.toggleFullScreen();
          }
        }
      },
      child: child,
    );
  }
}
