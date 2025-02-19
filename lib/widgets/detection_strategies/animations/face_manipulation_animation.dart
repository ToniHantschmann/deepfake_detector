import 'package:flutter/material.dart';
import 'face_manipulation_painter.dart';
import '../../../config/config.dart';

class FaceManipulationAnimation extends StatefulWidget {
  const FaceManipulationAnimation({Key? key}) : super(key: key);

  @override
  State<FaceManipulationAnimation> createState() =>
      _FaceManipulationAnimationState();
}

class _FaceManipulationAnimationState extends State<FaceManipulationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingManipulated = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    if (_showingManipulated) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _updateFaceMode(bool manipulated) {
    if (_showingManipulated != manipulated) {
      setState(() {
        _showingManipulated = manipulated;
        _startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: FaceManipulationPainter(_animation.value),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildControls(),
        const SizedBox(height: 16),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton(AppConfig.strings.strategyCard.toggleOriginal, false),
        const SizedBox(width: 16),
        _buildModeButton(
            AppConfig.strings.strategyCard.toggleManipulated, true),
      ],
    );
  }

  Widget _buildModeButton(String label, bool isManipulated) {
    final isSelected = _showingManipulated == isManipulated;
    return TextButton(
      onPressed: () => _updateFaceMode(isManipulated),
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

  Widget _buildIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _showingManipulated
            ? Colors.red.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face,
            size: 16,
            color: _showingManipulated ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            _showingManipulated
                ? AppConfig
                    .strings.strategyCard.faceManipulationIndicatorManipulated
                : AppConfig
                    .strings.strategyCard.faceManipulationIndicatorNormal,
            style: TextStyle(
              color: _showingManipulated ? Colors.red : Colors.green,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
