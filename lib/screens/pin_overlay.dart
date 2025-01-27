import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../widgets/auth/auth_overlay_base.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PinOverlay extends StatelessWidget {
  final String pin;
  final VoidCallback onClose;

  const PinOverlay({
    Key? key,
    required this.pin,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthOverlayBase(
      title: 'Your PIN',
      onClose: onClose,
      children: [
        const Text(
          'Save this PIN to access your statistics later',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: pin
              .split('')
              .map((digit) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        digit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: pin));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy PIN'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onClose();
              context.read<GameBloc>().add(const RestartGame());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Next Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
