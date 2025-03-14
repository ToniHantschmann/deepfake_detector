// lib/widgets/detection_strategies/animations/common/animation_base_generic.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../config/app_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/game/game_bloc.dart';
import '../../../../blocs/game/game_state.dart';

abstract class GenericStrategyAnimationBase extends StatefulWidget {
  const GenericStrategyAnimationBase({Key? key}) : super(key: key);

  @override
  State<GenericStrategyAnimationBase> createState() =>
      GenericStrategyAnimationBaseState();
}

class GenericStrategyAnimationBaseState<T extends GenericStrategyAnimationBase>
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  bool isActive = false;
  bool _isVisible = true;
  bool _isMounted = false;
  Key _visibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    animationController = AnimationController(
      vsync: this,
      duration: AppConfig.animation.normal,
    );

    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: AppConfig.animation.standard,
    ));
  }

  // Verfolgt, ob Widget sichtbar ist
  void _setVisibility(bool isVisible) {
    if (!_isMounted) return;

    // Nur State aktualisieren, wenn sich etwas ändert
    if (_isVisible != isVisible) {
      // Zustandsvariable aktualisieren ohne setState aufzurufen
      _isVisible = isVisible;

      if (!_isVisible) {
        _pauseAnimationInternal();
      } else if (isActive) {
        _resumeAnimationInternal();
      }
    }
  }

  // Interne Methoden für Animation ohne setState
  void _pauseAnimationInternal() {
    if (!_isMounted) return;
    animationController.stop();
  }

  void _resumeAnimationInternal() {
    if (!_isMounted || !_isVisible || !isActive) return;

    if (animationController.isCompleted) {
      animationController.forward(from: 0.0);
    } else {
      animationController.forward(from: animationController.value);
    }
  }

  // Sichere Methoden, die von Kindklassen verwendet werden können
  void safeSetState(VoidCallback fn) {
    if (!_isMounted) return;

    // Führe setState verzögert auf den nächsten Frame aus, um Build-Konflikte zu vermeiden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        try {
          setState(fn);
        } catch (e) {
          // Logging oder Fehlerbehandlung hier
          print('setState failed: $e');
        }
      }
    });
  }

  void updateActiveState(bool active) {
    if (!_isMounted) return;

    if (isActive != active) {
      // Sichere setState-Aktualisierung
      setState(() {
        isActive = active;
      });

      if (active && _isVisible) {
        startAnimation();
      } else {
        stopAnimation();
      }
    }
  }

  void startAnimation() {
    if (!_isMounted || !_isVisible) return;
    animationController.forward();
  }

  void stopAnimation() {
    if (!_isMounted) return;
    animationController.stop();
    animationController.reset();
  }

  void pauseAnimation() {
    if (!_isMounted) return;
    animationController.stop();
  }

  void resumeAnimation() {
    if (!_isMounted || !_isVisible || !isActive) return;

    if (animationController.isCompleted) {
      animationController.forward(from: 0.0);
    } else {
      animationController.forward(from: animationController.value);
    }
  }

  @override
  void activate() {
    super.activate();
    _isMounted = true;
  }

  @override
  void deactivate() {
    _pauseAnimationInternal();
    super.deactivate();
  }

  @override
  void dispose() {
    _isMounted = false;
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) => previous.locale != current.locale,
        builder: (context, _) {
          final strings =
              AppConfig.getStrings(context.currentLocale).strategyCard;
          return Column(
            children: [
              buildAnimationContainer(),
              SizedBox(height: AppConfig.layout.spacingLarge),
              _buildControlButton(strings),
              SizedBox(height: AppConfig.layout.spacingMedium),
              _buildStatusIndicator(strings),
            ],
          );
        });
  }

  Widget buildAnimationContainer() {
    // Strategischer Key-Wechsel, um Lifecycle-Probleme zu umgehen
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: (info) {
          // Als sichtbar betrachten, wenn mehr als 10% im Viewport sind
          _setVisibility(info.visibleFraction > 0.1);
        },
        child: buildAnimation(),
      ),
    );
  }

  Widget buildAnimation() {
    // To be overridden by concrete animation implementations
    return const SizedBox();
  }

  Widget _buildControlButton(StrategyCardStrings strings) {
    return TextButton(
      onPressed: () => updateActiveState(!isActive),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        isActive
            ? strings.researchStatusInProgress
            : strings.researchButtonText,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(StrategyCardStrings strings) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.search : Icons.info_outline,
            size: 16,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? strings.researchTip : strings.researchStatusNone,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
