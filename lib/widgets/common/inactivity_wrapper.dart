import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import '../../config/app_config.dart';
import '../overlays/countdown_overlay.dart';

class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const InactivityWrapper({
    Key? key,
    required this.child,
    this.timeout = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;
  Timer? _countdownTimer;
  bool _isShowingCountdown = false;
  int _countdownSeconds = 10; // 10 seconds countdown

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, _onInactivityDetected);
  }

  void _resetTimers() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    if (_isShowingCountdown && mounted) {
      setState(() {
        _isShowingCountdown = false;
      });
    }
    _countdownSeconds = 10;
    _startTimer();
  }

  void _onInactivityDetected() {
    // Get current game state
    final gameBloc = context.read<GameBloc>();
    final currentScreen = gameBloc.state.currentScreen;

    // If we're already on the introduction screen, just reset the timer and don't show countdown
    if (currentScreen == GameScreen.introduction) {
      _resetTimers();
      return;
    }

    // Otherwise show the countdown as normal
    if (mounted) {
      setState(() {
        _isShowingCountdown = true;
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 1) {
            _countdownSeconds--;
          } else {
            _countdownTimer?.cancel();
            _isShowingCountdown = false;
            _onInactivityTimeout();
          }
        });
      }
    });
  }

  void _onInactivityTimeout() {
    final gameBloc = context.read<GameBloc>();
    gameBloc.add(const InitializeGame());
    _resetTimers();
  }

  void _onUserInteraction() {
    // If we're showing the countdown, cancel it
    if (_isShowingCountdown) {
      setState(() {
        _isShowingCountdown = false;
        _countdownTimer?.cancel();
      });
    }

    // Restart the inactivity timer
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerUp: (_) => _onUserInteraction(),
      child: Stack(
        children: [
          widget.child,
          if (_isShowingCountdown)
            CountdownOverlay(
              secondsRemaining: _countdownSeconds,
              onContinue: () {
                setState(() {
                  _isShowingCountdown = false;
                  _countdownTimer?.cancel();
                  _startTimer();
                });
              },
            ),
        ],
      ),
    );
  }
}
