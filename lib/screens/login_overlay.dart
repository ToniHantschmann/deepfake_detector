import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/auth/auth_overlay_base.dart';
import '../widgets/auth/pin_display.dart';
import '../widgets/auth/number_pad.dart';

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({Key? key}) : super(key: key);

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  String _pin = '';
  String? _errorMessage;

  void _handleNumberInput(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _verifyPin() {
    context.read<GameBloc>().add(LoginWithPin(_pin));
    Navigator.of(context).pop();
  }

  void _handleClose() {
    context.read<GameBloc>().add(const CancelLogin());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.error) {
          setState(() {
            _errorMessage = state.errorMessage;
            _pin = '';
          });
        }
      },
      builder: (context, state) {
        return AuthOverlayBase(
          title: 'Enter PIN',
          onClose: _handleClose,
          children: [
            const Text(
              'Enter your 4-digit PIN to continue',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PinDisplay(pin: _pin),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            NumberPad(
              onNumberPressed: _handleNumberInput,
              onBackspacePressed: _handleBackspace,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<GameBloc>().add(const QuickStartGame());
              },
              child: const Text(
                'Continue without PIN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
