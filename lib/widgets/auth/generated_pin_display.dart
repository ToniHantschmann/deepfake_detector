import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeneratedPinDisplay extends StatelessWidget {
  final String pin;
  final Color? accentColor;

  const GeneratedPinDisplay({
    Key? key,
    required this.pin,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your PIN has been generated!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...pin.split('').map((digit) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.3),
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
                  )),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Use this PIN to access your statistics on your next visit.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
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
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
