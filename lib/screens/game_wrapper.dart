import 'package:deepfake_detector/screens/qr_code_screen.dart';
import 'package:deepfake_detector/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/statistics_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart';
import '../repositories/internal_statistics_repository.dart';
import '../screens/video_screen.dart';
import '../screens/introduction_screen.dart';
import 'decision_screen.dart';
import '../screens/result_screen.dart';
import '../screens/strategies_screen.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/inactivity_wrapper.dart';

/// Wrapper class to manage gameStates and data for all screens
class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        videoRepository: VideoRepository(),
        statisticsRepository: StatisticsRepository(),
        userRepository: UserRepository(),
        internalStatsRepository: InternalStatisticsRepository(),
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
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentScreen != current.currentScreen,
      builder: (context, state) {
        if (state.status == GameStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == GameStatus.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GameBloc>().add(const InitializeGame()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return InactivityWrapper(child: _buildCurrentScreen(state));
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

      case GameScreen.decision:
        return const DecisionScreen();

      case GameScreen.result:
        return const ResultScreen();

      case GameScreen.strategy:
        return const StrategiesScreen();

      case GameScreen.statistics:
        return const StatisticsScreen();

      case GameScreen.qrCode:
        return const QrCodeScreen();

      default:
        return const IntroductionScreen();
    }
  }
}
