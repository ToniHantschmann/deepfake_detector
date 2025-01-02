import 'package:deepfake_detector/screens/game_wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DeepfakeDetectorApp());
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
