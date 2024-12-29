import 'package:deepfake_detector/blocs/game_bloc.dart';
import 'package:deepfake_detector/screens/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        home: BlocProvider(
          create: (context) => GameBloc(),
          child: const IntroductionScreen(),
        ));
  }
}
