// lib/widgets/detection_strategies/animations/common/animation_base.dart

import 'package:flutter/material.dart';
import '../../../../config/config.dart';
import 'animation_controls.dart';
import 'indicators.dart';

abstract class StrategyAnimationBase extends StatefulWidget {
  const StrategyAnimationBase({Key? key}) : super(key: key);

  @override
  State<StrategyAnimationBase> createState() => StrategyAnimationBaseState();
}

class StrategyAnimationBaseState<T extends StrategyAnimationBase>
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  bool showingManipulated = false;

  @override
  void initState() {
    super.initState();
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

    startAnimation();
  }

  void startAnimation() {
    if (showingManipulated) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  void updateMode(bool manipulated) {
    if (showingManipulated != manipulated) {
      setState(() {
        showingManipulated = manipulated;
        startAnimation();
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildAnimationContainer(),
        SizedBox(height: AppConfig.layout.spacingLarge),
        AnimationControls(
          isManipulated: showingManipulated,
          onModeChanged: updateMode,
        ),
        SizedBox(height: AppConfig.layout.spacingMedium),
        AnimationIndicator(
          isManipulated: showingManipulated,
          normalText:
              AppConfig.strings.strategyCard.faceManipulationIndicatorNormal,
          manipulatedText: AppConfig
              .strings.strategyCard.faceManipulationIndicatorManipulated,
        ),
      ],
    );
  }

  Widget buildAnimationContainer() {
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: buildAnimation(),
    );
  }

  Widget buildAnimation() {
    // Zu überschreiben von konkreten Animations-Widgets
    return const SizedBox();
  }
}
