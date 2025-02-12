import 'package:flutter/material.dart';
import '../../../config/config.dart';

class ScrollIndicator extends StatefulWidget {
  final Alignment alignment;
  final VoidCallback? onTap;

  const ScrollIndicator({
    Key? key,
    required this.alignment,
    this.onTap,
  }) : super(key: key);

  @override
  State<ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 40,
        margin: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.spacingSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: widget.alignment == Alignment.centerLeft
                ? Alignment.centerRight
                : Alignment.centerLeft,
            end: widget.alignment == Alignment.centerLeft
                ? Alignment.centerLeft
                : Alignment.centerRight,
            colors: [
              AppConfig.colors.background.withOpacity(0),
              AppConfig.colors.background,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
          },
          child: Icon(
            widget.alignment == Alignment.centerLeft
                ? Icons.chevron_left
                : Icons.chevron_right,
            color: AppConfig.colors.textSecondary,
            size: 32,
          ),
        ),
      ),
    );
  }
}
