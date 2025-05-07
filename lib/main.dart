import 'package:deepfake_detector/screens/game_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_html/html.dart' show window;
import 'package:flutter/foundation.dart';
import './storage/game_attempt_adapter.dart';
import './storage/user_statistics_adapter.dart';
import 'repositories/internal_statistics_repository.dart';

bool get isElectron => kIsWeb && window.location.protocol == 'file:';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initStorage();
  InternalStatisticsRepository().registerConsoleCommands();
  runApp(const DeepfakeDetectorApp());
}

void initStorage() async {
  // Modifizierte Initialisierung für Electron-Kompatibilität
  if (kIsWeb && isElectron) {
    // In Electron, verwende einen spezifischen Speicherpfad
    await Hive.initFlutter('deepfake_detector_storage');
  } else {
    // Normale Initialisierung
    await Hive.initFlutter();
  }

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
