import 'package:flutter/material.dart';
import '../../models/strategy_model.dart';
import '../../config/config.dart';
import 'strategy_card.dart';

class ExpandableStrategyList extends StatelessWidget {
  final List<Strategy> previewStrategies;
  final List<Strategy> expandedStrategies;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ExpandableStrategyList({
    Key? key,
    required this.previewStrategies,
    required this.expandedStrategies,
    required this.isExpanded,
    required this.onToggleExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 2 - AppConfig.layout.spacingLarge;

    return Column(
      children: [
        // Preview strategies (always visible)
        SizedBox(
          height: 500, // Feste Höhe für die Strategy-Cards
          child: _buildStrategiesRow(previewStrategies, cardWidth),
        ),

        // Expandable section
        AnimatedCrossFade(
          firstChild: _buildExpandButton(),
          secondChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 500, // Gleiche Höhe für expandierte Strategien
                child: _buildStrategiesRow(expandedStrategies, cardWidth),
              ),
              _buildCollapseButton(),
            ],
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: AppConfig.animation.normal,
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildStrategiesRow(List<Strategy> strategies, double cardWidth) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? AppConfig.layout.spacingMedium : 0,
            right: AppConfig.layout.spacingMedium,
          ),
          child: SizedBox(
            width: cardWidth,
            child: StrategyCard(strategy: strategies[index]),
          ),
        );
      },
    );
  }

  Widget _buildExpandButton() {
    return _buildToggleButton(
      icon: Icons.keyboard_arrow_down,
      label: 'Show More Strategies',
    );
  }

  Widget _buildCollapseButton() {
    return _buildToggleButton(
      icon: Icons.keyboard_arrow_up,
      label: 'Show Less',
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConfig.layout.spacingMedium),
      child: InkWell(
        onTap: onToggleExpand,
        borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingMedium,
            horizontal: AppConfig.layout.spacingLarge,
          ),
          decoration: BoxDecoration(
            color: AppConfig.colors.backgroundLight,
            borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppConfig.colors.textPrimary,
              ),
              SizedBox(width: AppConfig.layout.spacingSmall),
              Text(
                label,
                style: AppConfig.textStyles.buttonMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
