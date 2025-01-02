import 'package:deepfake_detector/blocs/game/game_event.dart';
import 'package:deepfake_detector/repositories/statistics_repository.dart';
import 'package:deepfake_detector/repositories/user_repository.dart';
import 'package:deepfake_detector/repositories/video_repository.dart';
import 'package:deepfake_detector/screens/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/introduction_screen.dart';

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
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      // TODO: implement switch logic for different screens
      switch (state.currentScreen) {
        case GameScreen.introduction:
          return IntroductionScreen(
              onStart: () => context.read<GameBloc>().add(NextScreen()));
        case GameScreen.firstVideo:
          return VideoScreen(
              onNext: () => context.read<GameBloc>().add(NextScreen()),
              video: state.videos.first,
              isFirstVideo: true);
        case GameScreen.secondVideo:
          return VideoScreen(
              video: state.videos.last,
              onNext: () => context.read<GameBloc>().add(NextScreen()),
              isFirstVideo: false);

        default:
          return const Center(
            child: Text('Unknown state'),
          );
      }
    });
  }
}
