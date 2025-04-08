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

  const InactivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;
  Timer? _countdownTimer;
  bool _isShowingCountdown = false;

  // Configuration values from AppConfig
  final Duration _timeout = AppConfig.timing.inactivityTimeout;
  final int _countdownDuration = AppConfig.timing.countdownTimeout.inSeconds;

  // Current countdown value (mutable)
  late int _currentCountdown;

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
    _timer = Timer(_timeout, _onInactivityDetected);
  }

  void _resetTimers() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    if (_isShowingCountdown && mounted) {
      setState(() {
        _isShowingCountdown = false;
      });
    }
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
        // Initialize current countdown from the config value
        _currentCountdown = _countdownDuration;
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_currentCountdown > 1) {
            _currentCountdown--;
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
      _resetTimers();
    } else {
      // Just restart the inactivity timer if countdown is not showing
      _startTimer();
    }
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
              secondsRemaining: _currentCountdown,
              onContinue: () => _resetTimers(),
            ),
        ],
      ),
    );
  }
}
