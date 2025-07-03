// lib/widgets/overlays/result_feedback_overlay.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../config/localization/string_types.dart';

class ResultFeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final ResultScreenStrings strings;
  final VoidCallback onDismiss;
  final Duration autoDismissDelay;

  const ResultFeedbackOverlay({
    Key? key,
    required this.isCorrect,
    required this.strings,
    required this.onDismiss,
    this.autoDismissDelay = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<ResultFeedbackOverlay> createState() => _ResultFeedbackOverlayState();
}

class _ResultFeedbackOverlayState extends State<ResultFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _autoDismissTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Start animation
    _animationController.forward();

    // Set up auto-dismiss timer
    _startAutoDismissTimer();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(widget.autoDismissDelay, widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: Colors.transparent,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(AppConfig.layout.spacingLarge * 1.5),
                  decoration: BoxDecoration(
                    color: widget.isCorrect
                        ? AppConfig.colors.success
                        : AppConfig.colors.wrongAnswer,
                    borderRadius:
                        BorderRadius.circular(AppConfig.layout.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isCorrect ? Icons.check_circle : Icons.error,
                        color: AppConfig.colors.textPrimary,
                        size: 64,
                      ),
                      SizedBox(height: AppConfig.layout.spacingXLarge),
                      Text(
                        widget.isCorrect
                            ? widget.strings.correctTitle
                            : widget.strings.wrongTitle,
                        style: AppConfig.textStyles.h2.copyWith(
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConfig.layout.spacingLarge),
                      Text(
                        widget.strings.tapToContinue,
                        style: AppConfig.textStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
