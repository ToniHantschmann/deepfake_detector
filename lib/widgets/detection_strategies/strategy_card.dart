import 'package:flutter/material.dart';
import '../../models/strategy_model.dart';
import '../../config/config.dart';

class StrategyCard extends StatelessWidget {
  final Strategy strategy;

  const StrategyCard({
    Key? key,
    required this.strategy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.cardPadding),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strategy.title,
            style: AppConfig.textStyles.h3,
          ),
          SizedBox(height: AppConfig.layout.spacingSmall),
          Text(
            strategy.description,
            style: AppConfig.textStyles.bodyMedium.copyWith(
              color: AppConfig.colors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Center(
              child: strategy.animation,
            ),
          ),
        ],
      ),
    );
  }
}
