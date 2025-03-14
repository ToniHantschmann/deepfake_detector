// lib/widgets/detection_strategies/animations/common/animation_base.dart

import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import '../../../../config/app_config.dart';
import 'animation_controls.dart';
import 'indicators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/game/game_bloc.dart';
import '../../../../blocs/game/game_state.dart';

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
    return BlocBuilder<GameBloc, GameState>(
        buildWhen: (previous, current) => previous.locale != current.locale,
        builder: (context, _) {
          final strings =
              AppConfig.getStrings(context.currentLocale).strategyCard;
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
                normalText: strings
                    .indicatorNormal, // Generische Indikatorsprache verwenden
                manipulatedText: strings.indicatorArtificial,
              ),
            ],
          );
        });
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
