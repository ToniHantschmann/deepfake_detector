import 'package:deepfake_detector/blocs/game/game_event.dart';
import 'package:deepfake_detector/repositories/statistics_repository.dart';
import 'package:deepfake_detector/repositories/user_repository.dart';
import 'package:deepfake_detector/repositories/video_repository.dart';
import 'package:deepfake_detector/screens/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/introduction_screen.dart';
import '../screens/comparison_screen.dart';
import '../screens/result_screen.dart';

import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';

/// wrapper class to manage gameStates and data for all screens
///
class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        videoRepository: VideoRepository(),
        statisticsRepository: StatisticsRepository(),
        userRepository: UserRepository(),
      ),
      child: const GameWrapperView(),
    );
  }
}

class GameWrapperView extends StatelessWidget {
  const GameWrapperView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildCurrentScreen(state);
      },
    );
  }

  Widget _buildCurrentScreen(GameState state) {
    switch (state.currentScreen) {
      case GameScreen.introduction:
        return const IntroductionScreen();

      case GameScreen.firstVideo:
        if (state.videos.isEmpty) {
          throw Exception('No videos available');
        }
        return VideoScreen(
          video: state.videos.first,
          isFirstVideo: true,
        );

      case GameScreen.secondVideo:
        if (state.videos.length < 2) {
          throw Exception('Second video not available');
        }
        return VideoScreen(
          video: state.videos.last,
          isFirstVideo: false,
        );

      case GameScreen.comparison:
        return const ComparisonScreen();

      case GameScreen.result:
        return const ResultScreen();

      case GameScreen.statistics:
        // TODO: Implement StatisticsScreen
        throw UnimplementedError('Statistics screen not implemented yet');

      case GameScreen.login:
        // TODO: Implement LoginScreen
        throw UnimplementedError('Login screen not implemented yet');

      default:
        throw Exception('Unknown screen state');
    }
  }
}
