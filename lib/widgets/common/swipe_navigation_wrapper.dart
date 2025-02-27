import 'package:flutter/material.dart';
import '../../blocs/game/game_state.dart';
import '../../config/app_config.dart';

class SwipeNavigationWrapper extends StatefulWidget {
  final Widget child;
  final GameScreen currentScreen;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool enableNext;

  const SwipeNavigationWrapper({
    Key? key,
    required this.child,
    required this.currentScreen,
    this.onNext,
    this.onBack,
    this.enableNext = true,
  }) : super(key: key);

  @override
  State<SwipeNavigationWrapper> createState() => _SwipeNavigationWrapperState();
}

class _SwipeNavigationWrapperState extends State<SwipeNavigationWrapper>
    with SingleTickerProviderStateMixin {
  double _dragDistance = 0.0;
  late AnimationController _animationController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resetAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.addListener(() {
      setState(() {
        _dragDistance = _resetAnimation.value;
      });
    });
  }

  // Helper-Methode zum Zurücksetzen der Drag-Distanz mit Animation
  void _resetDragDistance() {
    _resetAnimation = Tween<double>(
      begin: _dragDistance,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Dämpfungsfaktor für natürliche Bewegung
    const double dampingFactor = 0.5;

    // Spezielle Einschränkungen für bestimmte Screens
    // Intro Screen: Keine vorwärts-Swipe-Navigation erlauben
    if (widget.currentScreen == GameScreen.introduction &&
        details.delta.dx < 0) {
      return;
    }

    // First Video Screen: Keine rückwärts-Swipe-Navigation zum Intro erlauben
    if (widget.currentScreen == GameScreen.firstVideo && details.delta.dx > 0) {
      return;
    }

    // Prüfe, ob die Wischrichtung mit einer erlaubten Navigationsrichtung übereinstimmt
    // Links wischen -> vorwärts, nur wenn vorwärts Navigation möglich ist
    // Rechts wischen -> zurück, nur wenn Zurück-Navigation möglich ist
    if ((details.delta.dx < 0 && !widget.currentScreen.canNavigateForward) ||
        (details.delta.dx > 0 && !widget.currentScreen.canNavigateBack)) {
      // Wische in eine nicht-navigierbare Richtung, ignoriere
      return;
    }

    setState(() {
      _dragDistance += details.delta.dx * dampingFactor;

      // Begrenze die Drag-Distanz
      final double maxDragDistance = MediaQuery.of(context).size.width * 0.15;
      _dragDistance = _dragDistance.clamp(-maxDragDistance, maxDragDistance);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double velocityThreshold =
        300.0; // Geschwindigkeitsschwelle in Pixel/s
    final double distanceThreshold =
        screenWidth * 0.1; // 10% der Bildschirmbreite

    bool shouldNavigate = false;
    bool isForward = false;

    // Spezielle Einschränkungen für bestimmte Screens
    // Intro Screen: Keine vorwärts-Swipe-Navigation erlauben
    if (widget.currentScreen == GameScreen.introduction && _dragDistance < 0) {
      // Navigiere nicht, sondern setze nur zurück
      _resetDragDistance();
      return;
    }

    // First Video Screen: Keine rückwärts-Swipe-Navigation zum Intro erlauben
    if (widget.currentScreen == GameScreen.firstVideo && _dragDistance > 0) {
      // Navigiere nicht, sondern setze nur zurück
      _resetDragDistance();
      return;
    }

    // Prüfe ob die Geschwindigkeit oder Distanz ausreicht für eine Navigation
    if (details.velocity.pixelsPerSecond.dx.abs() > velocityThreshold ||
        _dragDistance.abs() > distanceThreshold) {
      // Bestimme die Richtung basierend auf Drag-Richtung und entsprechender GameScreenNavigation extension
      // Nach rechts swipen -> zurück, aber nur wenn der aktuelle Screen zurück navigieren kann
      if (_dragDistance > 0 &&
          widget.currentScreen.canNavigateBack &&
          widget.onBack != null) {
        shouldNavigate = true;
        isForward = false;
      }
      // Nach links swipen -> weiter, aber nur wenn der aktuelle Screen vorwärts navigieren kann
      else if (_dragDistance < 0 &&
          widget.currentScreen.canNavigateForward &&
          widget.onNext != null &&
          widget.enableNext) {
        shouldNavigate = true;
        isForward = true;
      }
    }

    // Animiere zurück zur Ausgangsposition
    _resetDragDistance();

    // Führe Navigation aus nach der Animation
    if (shouldNavigate) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (isForward && widget.onNext != null) {
          widget.onNext!();
        } else if (!isForward && widget.onBack != null) {
          widget.onBack!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bestimme, ob Navigation in jede Richtung möglich ist
    final bool canGoBack =
        widget.currentScreen.canNavigateBack && widget.onBack != null;
    final bool canGoForward = widget.currentScreen.canNavigateForward &&
        widget.onNext != null &&
        widget.enableNext;

    // Wenn keine Richtung navigierbar ist, einfach direkt das Kind zurückgeben
    if (!canGoBack && !canGoForward) {
      return widget.child;
    }

    return Stack(
      children: [
        // Hintergrund-Layer, der die App-Hintergrundfarbe hat
        // Dieser bedeckt den gesamten Screen und verhindert weiße Ränder
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppConfig.colors.background, // App-Hintergrundfarbe
        ),

        // Layer mit dem eigentlichen Content, der geswiped wird
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Transform.translate(
            offset: Offset(_dragDistance, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
