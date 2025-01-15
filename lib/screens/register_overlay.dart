// lib/screens/register_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../widgets/auth/auth_overlay_base.dart';
import '../widgets/auth/pin_display.dart';
import '../widgets/auth/number_pad.dart';
import '../utils/pin_validator.dart';
import '../utils/username_validator.dart';

class RegisterOverlay extends StatefulWidget {
  const RegisterOverlay({Key? key}) : super(key: key);

  @override
  State<RegisterOverlay> createState() => _RegisterOverlayState();
}

class _RegisterOverlayState extends State<RegisterOverlay> {
  final TextEditingController _usernameController = TextEditingController();
  String _pin = '';
  bool _isConfirmingPin = false;
  String _confirmPin = '';
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleNumberInput(String number) {
    if (_isConfirmingPin) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += number;
          _errorMessage = null;
        });

        if (_confirmPin.length == 4) {
          _validatePins();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin += number;
          _errorMessage = null;
        });

        if (_pin.length == 4) {
          setState(() {
            _isConfirmingPin = true;
          });
        }
      }
    }
  }

  void _handleBackspace() {
    if (_isConfirmingPin) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _errorMessage = null;
        });
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _errorMessage = null;
        });
      }
    }
  }

  void _validatePins() {
    if (!PinValidator.doPinsMatch(_pin, _confirmPin)) {
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPin = '';
      });
      return;
    }

    _handleRegistration();
  }

  void _handleRegistration() {
    final username = _usernameController.text.trim();
    final usernameError = UsernameValidator.validate(username);

    if (usernameError != null) {
      setState(() {
        _errorMessage = usernameError;
      });
      return;
    }

    context.read<GameBloc>().add(RegisterNewUser(username));
    Navigator.of(context).pop();
  }

  void _handleClose() {
    context.read<GameBloc>().add(const CancelLogin());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthOverlayBase(
      title: 'Register Account',
      onClose: _handleClose,
      children: [
        if (!_isConfirmingPin) ...[
          _buildUsernameField(),
          const SizedBox(height: 24),
          const Text(
            'Choose a 4-digit PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ] else ...[
          const Text(
            'Confirm your PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
        const SizedBox(height: 16),
        PinDisplay(
          pin: _isConfirmingPin ? _confirmPin : _pin,
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
        ],
        NumberPad(
          onNumberPressed: _handleNumberInput,
          onBackspacePressed: _handleBackspace,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter username',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF262626),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
