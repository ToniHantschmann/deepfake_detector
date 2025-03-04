import 'package:flutter/material.dart';
import '../../models/strategy_model.dart';
import '../../config/app_config.dart';

class StrategyCard extends StatelessWidget {
  final Strategy strategy;
  final bool hasBeenViewed;

  const StrategyCard({
    Key? key,
    required this.strategy,
    this.hasBeenViewed = false, // Optional mit Standardwert
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConfig.layout.cardPadding),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
      ),
      child: Stack(
        children: [
          Column(
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
                  fontSize: 18.0, // Größere Schriftgröße hier
                  fontWeight: FontWeight
                      .w400, // Etwas stärkere Schrift für bessere Lesbarkeit
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
          // Checkbox indicator in top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: _buildViewedIndicator(),
          ),
        ],
      ),
    );
  }

  // Custom viewed indicator that matches app style
  Widget _buildViewedIndicator() {
    return Container(
      margin: const EdgeInsets.only(right: 4, top: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasBeenViewed
            ? AppConfig.colors.primary.withOpacity(0.2)
            : AppConfig.colors.backgroundDark.withOpacity(0.3),
      ),
      child: hasBeenViewed
          ? Icon(
              Icons.check,
              size: 16,
              color: AppConfig.colors.primary,
            )
          : null,
    );
  }
}
