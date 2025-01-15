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
  bool _showConfirmation = false;
  bool _showUserSelection = false;
  List<String> _matchingUsernames = [];
  String? _selectedUsername;
  String? _errorMessage;

  void _handleNumberInput(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _checkPin();
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

  void _checkPin() {
    context.read<GameBloc>().add(CheckPin(_pin));
  }

  void _handleConfirm() {
    if (_selectedUsername != null) {
      context.read<GameBloc>().add(LoginExistingUser(_selectedUsername!));
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    setState(() {
      _pin = '';
      _showConfirmation = false;
      _showUserSelection = false;
      _selectedUsername = null;
      _matchingUsernames = [];
      _errorMessage = null;
    });
  }

  void _handleClose() {
    context.read<GameBloc>().add(const CancelLogin());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.isPinChecking) return;

        if (state.pinMatchingUsernames.isEmpty) {
          setState(() {
            _pin = '';
            _errorMessage = 'Invalid PIN';
          });
        } else if (state.pinMatchingUsernames.length == 1) {
          setState(() {
            _showConfirmation = true;
            _selectedUsername = state.pinMatchingUsernames.first;
          });
        } else {
          setState(() {
            _showUserSelection = true;
            _matchingUsernames = state.pinMatchingUsernames;
          });
        }
      },
      builder: (context, state) {
        return AuthOverlayBase(
          title: _showConfirmation
              ? 'Confirm Identity'
              : _showUserSelection
                  ? 'Select Account'
                  : 'Enter PIN',
          onClose: _handleClose,
          children: [
            if (!_showConfirmation && !_showUserSelection) ...[
              PinDisplay(pin: _pin),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              NumberPad(
                onNumberPressed: _handleNumberInput,
                onBackspacePressed: _handleBackspace,
              ),
            ] else if (_showUserSelection) ...[
              _buildUserSelection(),
            ] else ...[
              _buildConfirmation(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildUserSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Multiple accounts found',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please select your account',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        ..._matchingUsernames.map((username) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedUsername = username;
                    _showUserSelection = false;
                    _showConfirmation = true;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF262626),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                child: Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _handleCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.grey[800],
            ),
            child: const Text(
              'Try different PIN',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.account_circle,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          _selectedUsername ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Is this your account?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _handleCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.grey[800],
                ),
                child: const Text(
                  'No, try again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Yes, that\'s me',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
