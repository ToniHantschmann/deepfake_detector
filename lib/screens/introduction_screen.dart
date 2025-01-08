// lib/screens/introduction_screen.dart

import 'package:deepfake_detector/blocs/game/game_event.dart';
import 'package:flutter/material.dart';
import 'base_game_screen.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_state.dart';

class IntroductionScreen extends BaseGameScreen {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    // Only rebuild if the screen or status changes
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
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
        const SizedBox(height: 16),
        _buildLoginButton(context),
      ],
    );
  }

  Widget _buildQuickStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => dispatchGameEvent(context, const QuickStartGame()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Quick Start',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => dispatchGameEvent(context, const ShowLogin()),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Login / Register',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
