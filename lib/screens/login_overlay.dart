import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import '../widgets/auth/auth_overlay_base.dart';
import '../widgets/auth/pin_display.dart';
import '../widgets/auth/number_pad.dart';
import '../config/app_config.dart';

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
    context.read<GameBloc>().add(LoginWithPin(int.parse(_pin)));
  }

  void _handleClose() {
    context.read<GameBloc>().add(const CancelLogin());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(context.currentLocale).auth;
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.playing) {
          Navigator.of(context).pop();
        } else if (state.status == GameStatus.loginError) {
          setState(() {
            _errorMessage = state.errorMessage;
            _pin = '';
          });
        }
      },
      builder: (context, state) {
        return AuthOverlayBase(
          title: strings.loginTitle,
          onClose: _handleClose,
          children: [
            Text(
              strings.loginSubtitle,
              style: AppConfig.textStyles.overlaySubtitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConfig.layout.spacingXLarge),
            PinDisplay(pin: _pin),
            if (_errorMessage != null) ...[
              SizedBox(height: AppConfig.layout.spacingMedium),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: AppConfig.colors.error,
                  fontSize: AppConfig.textStyles.bodySmall.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: AppConfig.layout.spacingXLarge),
            NumberPad(
              onNumberPressed: _handleNumberInput,
              onBackspacePressed: _handleBackspace,
            ),
            SizedBox(height: AppConfig.layout.spacingLarge),
            TextButton(
              onPressed: () {
                context.read<GameBloc>().add(const QuickStartGame());
              },
              child: Text(
                strings.continueWithoutPin,
                style: AppConfig.textStyles.bodyMedium.copyWith(
                  color: AppConfig.colors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
