import 'package:flutter/material.dart';
import 'facial_features_painter.dart';
import '../../../config/config.dart';

class FacialFeaturesAnimation extends StatefulWidget {
  const FacialFeaturesAnimation({Key? key}) : super(key: key);

  @override
  State<FacialFeaturesAnimation> createState() =>
      _FacialFeaturesAnimationState();
}

class _FacialFeaturesAnimationState extends State<FacialFeaturesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingNatural = true;

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
    if (_showingNatural) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _updateFeaturesMode(bool natural) {
    if (_showingNatural != natural) {
      setState(() {
        _showingNatural = natural;
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
                painter: FacialFeaturesPainter(_animation.value),
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
        _buildModeButton(AppConfig.strings.strategyCard.toggleOriginal, true),
        const SizedBox(width: 16),
        _buildModeButton(
            AppConfig.strings.strategyCard.toggleManipulated, false),
      ],
    );
  }

  Widget _buildModeButton(String label, bool isNatural) {
    final isSelected = _showingNatural == isNatural;
    return TextButton(
      onPressed: () => _updateFeaturesMode(isNatural),
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
        color: _showingNatural
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face,
            size: 16,
            color: _showingNatural ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _showingNatural
                ? AppConfig.strings.strategyCard.faceManipulationIndicatorNormal
                : AppConfig
                    .strings.strategyCard.faceManipulationIndicatorManipulated,
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
