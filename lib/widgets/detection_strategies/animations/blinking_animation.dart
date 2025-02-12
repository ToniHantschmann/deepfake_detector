import 'package:flutter/material.dart';
import 'face_painter.dart';

class BlinkingAnimation extends StatefulWidget {
  const BlinkingAnimation({Key? key}) : super(key: key);

  @override
  State<BlinkingAnimation> createState() => _BlinkingAnimationState();
}

class _BlinkingAnimationState extends State<BlinkingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingNatural = false;
  static const double _minEyeOpen = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: _minEyeOpen,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startBlinking();
  }

  void _startBlinking() {
    final interval = _showingNatural
        ? (const Duration(seconds: 4))
        : (const Duration(milliseconds: 800));

    Future.delayed(interval, () {
      if (!mounted) return;

      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _controller.reverse().then((_) => _startBlinking());
        });
      });
    });
  }

  void _updateBlinkingMode(bool natural) {
    setState(() {
      _showingNatural = natural;
      _controller.duration = Duration(milliseconds: natural ? 200 : 100);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feste Größe für die Animation
            SizedBox(
              width: 300, // Feste Breite
              height: 300, // Feste Höhe
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(300, 300), // Feste Größe für das CustomPaint
                      painter: FacePainter(_animation.value),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('Unnatural', false),
                  const SizedBox(width: 16),
                  _buildModeButton('Natural', true),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 32,
              child: _buildBlinkingIndicator(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeButton(String label, bool isNatural) {
    final isSelected = _showingNatural == isNatural;
    return TextButton(
      onPressed: () => _updateBlinkingMode(isNatural),
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

  Widget _buildBlinkingIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _showingNatural
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: _showingNatural ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _showingNatural
                ? 'Normal blinking interval (~ 4s)'
                : 'Unnatural fast blinking',
            style: TextStyle(
              color: _showingNatural ? Colors.green : Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
