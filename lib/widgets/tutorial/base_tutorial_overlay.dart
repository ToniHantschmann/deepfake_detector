// lib/widgets/tutorial/base_tutorial_overlay.dart

import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Basis-Klasse für alle Tutorial-Overlays
abstract class BaseTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration autoHideDuration;

  const BaseTutorialOverlay({
    Key? key,
    required this.onComplete,
    this.autoHideDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  BaseTutorialOverlayState createState();
}

abstract class BaseTutorialOverlayState<T extends BaseTutorialOverlay>
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  // Je nach Tutorial können diese Animationen überschrieben werden
  Animation<Offset>? slideAnimation;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Basis-Fade-Animation für alle Tutorials
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));

    // Tutorial-spezifische Animationen initialisieren
    setupAnimations();

    // Animation starten mit Verzögerung
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        animationController.repeat(reverse: true);
      }
    });

    // Auto-Dismiss nach bestimmter Zeit
    Future.delayed(widget.autoHideDuration, () {
      if (mounted) {
        dismiss();
      }
    });
  }

  // Überschreibbare Methode für Tutorial-spezifische Animationen
  void setupAnimations() {
    // Wird in Unterklassen implementiert
  }

  void dismiss() {
    widget.onComplete();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: dismiss,
        child: Container(
          color: AppConfig.colors.backgroundDark.withOpacity(0.8),
          child: Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: buildTutorialContent(context),
            ),
          ),
        ),
      ),
    );
  }

  // Von Unterklassen zu implementieren - Tutorial-spezifischer Inhalt
  Widget buildTutorialContent(BuildContext context);
}
