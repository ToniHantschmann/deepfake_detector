import 'package:deepfake_detector/screens/game_wrapper.dart';
import 'package:deepfake_detector/utils/window_manager.dart';
import 'package:deepfake_detector/widgets/common/options_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './storage/game_attempt_adapter.dart';
import './storage/user_statistics_adapter.dart';
import 'repositories/internal_statistics_repository.dart';
import 'package:deepfake_detector/utils/crash_logger.dart';

import 'dart:io';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleCrashLogger.initialize();

  MediaKit.ensureInitialized();

  // Windows-spezifische Initialisierung mit dem WindowManager
  if (Platform.isWindows) {
    await WindowManager.instance.initWindow();
  }

  await initStorage();
  InternalStatisticsRepository().registerDesktopCommands();
  runApp(const DeepfakeDetectorApp());
}

Future<void> initStorage() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserStatisticsAdapter());
  Hive.registerAdapter(GameAttemptAdapter());
}

class DeepfakeDetectorApp extends StatelessWidget {
  const DeepfakeDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Kein App-Bar-Schatten für nahtlosen Übergang zur OptionsToolbar
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      home: const AppRoot(),
      debugShowCheckedModeBanner: false, // Entfernt das Debug-Banner
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WindowManager.instance,
      builder: (context, child) {
        return AppShortcutManager(
          child: Column(
            children: [
              // OptionsToolbar, die nur im Fenstermodus sichtbar ist
              OptionsToolbar(),

              // Hauptinhalt der App
              Expanded(
                child: GameWrapper(),
              ),
            ],
          ),
        );
      },
    );
  }
}
