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
import '../screens/strategies_screen.dart';
import '../screens/login_overlay.dart';

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

class GameWrapperView extends StatefulWidget {
  const GameWrapperView({Key? key}) : super(key: key);

  @override
  State<GameWrapperView> createState() => _GameWrapperViewState();
}

class _GameWrapperViewState extends State<GameWrapperView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (previous, current) =>
          previous.showLoginOverlay != current.showLoginOverlay,
      listener: (context, state) {
        if (state.showLoginOverlay) {
          _showLoginDialog(context);
        }
      },
      builder: (context, state) {
        return _buildCurrentScreen(state);
      },
    );
  }

  Future<void> _showLoginDialog(BuildContext context) async {
    final bloc = context.read<GameBloc>();
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const LoginOverlay(),
      ),
    );

    if (mounted) {
      bloc.add(const CancelLogin());
    }
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
        return const StrategiesScreen();

      default:
        return const IntroductionScreen();
    }
  }
}
