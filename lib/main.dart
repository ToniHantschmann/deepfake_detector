import 'package:deepfake_detector/screens/game_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './storage/game_attempt_adapter.dart';
import './storage/user_statistics_adapter.dart';
import 'repositories/internal_statistics_repository.dart';

import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  // Windows-spezifische Initialisierung
  if (Platform.isWindows) {
    setWindowTitle('Deepfake Detector');
    setWindowMinSize(const Size(1024, 768));
    setWindowMaxSize(Size.infinite);
  }

  initStorage();
  InternalStatisticsRepository().registerDesktopCommands();
  runApp(const DeepfakeDetectorApp());
}

void initStorage() async {
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
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const GameWrapper(),
    );
  }
}
