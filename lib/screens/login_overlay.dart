// lib/screens/login_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import 'dart:ui';

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

  void _handleNumberInput(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });

      // Wenn PIN vollständig ist, simulieren wir einen API-Call
      if (_pin.length == 4) {
        _checkPin();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _checkPin() {
    context.read<GameBloc>().add(CheckPin(_pin));
  }

  void _handleConfirm() {
    if (_selectedUsername != null) {
      context.read<GameBloc>().add(LoginExistingUser(_selectedUsername!));
    }
  }

  void _handleCancel() {
    setState(() {
      _pin = '';
      _showConfirmation = false;
      _showUserSelection = false;
      _selectedUsername = null;
      _matchingUsernames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.isPinChecking) return;

        if (state.pinMatchingUsernames.isEmpty) {
          setState(() {
            _pin = '';
            // TODO: Show error message
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
        if (state.isPinChecking) {
          return Container(
            color: Colors.black.withOpacity(0.8),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          color: Colors.black.withOpacity(0.8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showConfirmation
                              ? 'Confirm Identity'
                              : _showUserSelection
                                  ? 'Select Account'
                                  : 'Enter PIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            context.read<GameBloc>().add(const CancelLogin());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (!_showConfirmation && !_showUserSelection) ...[
                      // PIN Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 56,
                            height: 56,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: index < _pin.length
                                    ? Colors.blue
                                    : Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: index < _pin.length
                                  ? const Icon(Icons.circle,
                                      size: 12, color: Colors.blue)
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Number Pad
                      ...List.generate(3, (row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (col) {
                              final number = (row * 3 + col + 1).toString();
                              return _buildNumberButton(number);
                            }),
                          ),
                        );
                      }),

                      // Bottom Row (0 and backspace)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildNumberButton('0'),
                          _buildBackspaceButton(),
                        ],
                      ),
                    ] else if (_showUserSelection) ...[
                      // User Selection Screen
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
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _matchingUsernames.length,
                          itemBuilder: (context, index) {
                            final username = _matchingUsernames[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
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
                            );
                          },
                        ),
                      ),
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
                    ] else ...[
                      // Confirmation Screen
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.grey[800],
                              ),
                              child: const Text('No, try again'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleConfirm,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Yes, that\'s me'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 72,
      height: 72,
      child: TextButton(
        onPressed: () => _handleNumberInput(number),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 72,
      height: 72,
      child: TextButton(
        onPressed: _handleBackspace,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF262626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Icon(
          Icons.backspace_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
