import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/introduction_screen.dart';

import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';

/// wrapper class to manage gameStates and data for all screens
///
class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
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
      return IntroductionScreen();
    });
  }
}
