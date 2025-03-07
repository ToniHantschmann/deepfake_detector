import 'package:flutter/material.dart';

/// Widget zur einfachen Animation zwischen einem originalen (echten) und einem gefälschten Bild
class MorphingAnimation extends StatefulWidget {
  final String realImagePath;
  final String fakeImagePath;
  final Duration duration;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MorphingAnimation({
    Key? key,
    required this.realImagePath,
    required this.fakeImagePath,
    this.duration = const Duration(seconds: 3),
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<MorphingAnimation> createState() => _MorphingAnimationState();
}

class _MorphingAnimationState extends State<MorphingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Auto-reverse und wiederholen
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base image (real)
        _buildImage(widget.realImagePath),

        // Animated overlay image (fake)
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: child,
            );
          },
          child: _buildImage(widget.fakeImagePath),
        ),

        // Animation zwischen "REAL" und "DEEPFAKE" Label
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isDeepfake = _animation.value > 0.5;
            return Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDeepfake
                      ? Colors.red.withOpacity(0.8)
                      : Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDeepfake ? 'DEEPFAKE' : 'REAL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImage(String path) {
    final image = Image.asset(
      path,
      fit: widget.fit,
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
