import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';
import '../blocs/game/game_event.dart';

class IntroductionScreen extends BaseGameScreen {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dispatchGameEvent(context, const ShowLogin()),
        label: const Text(
          'Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(Icons.login),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Deepfake Detector',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLeftColumn()),
              const SizedBox(width: 32),
              Expanded(child: _buildRightColumn(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(),
              const SizedBox(height: 32),
              _buildRightColumn(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Picture',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(color: Color(0xFF7F1D1D)),
          child: const Text(
            'Can you spot the difference?',
            style: TextStyle(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test your ability to detect deepfake videos in this interactive challenge.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "You'll be shown two videos - one real and one deepfake. Your task is to identify which one is the fake.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildQuickStartButton(context),
      ],
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 80,
        child: ElevatedButton(
          onPressed: () => dispatchGameEvent(context, const QuickStartGame()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Quick Start',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
