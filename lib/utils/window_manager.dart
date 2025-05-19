// lib/utils/window_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
