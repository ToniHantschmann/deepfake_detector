import 'package:flutter/material.dart';
import 'lip_painter.dart';

class LipSyncAnimation extends StatefulWidget {
  const LipSyncAnimation({Key? key}) : super(key: key);

  @override
  State<LipSyncAnimation> createState() => _LipSyncAnimationState();
}

class _LipSyncAnimationState extends State<LipSyncAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingNatural = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation(bool natural) {
    setState(() {
      _showingNatural = natural;
      _controller.duration = Duration(milliseconds: natural ? 500 : 200);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(120, 60),
              painter: LipPainter(_animation.value),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton('Synchron', true),
            const SizedBox(width: 16),
            _buildModeButton('Asynchron', false),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, bool isNatural) {
    final isSelected = _showingNatural == isNatural;
    return TextButton(
      onPressed: () => _updateAnimation(isNatural),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}
