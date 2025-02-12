import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/strategy_model.dart';
import '../../../config/config.dart';
import '../strategy_card.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class StrategyCarousel extends StatefulWidget {
  final List<Strategy> strategies;
  final double viewportFraction;
  final Function(int)? onPageChanged;

  const StrategyCarousel({
    Key? key,
    required this.strategies,
    this.viewportFraction = 0.4,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<StrategyCarousel> createState() => _StrategyCarouselState();
}

class _StrategyCarouselState extends State<StrategyCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Starte in der Mitte der "unendlichen" Liste
    _currentPage = widget.strategies.length * 100;
    _pageController = PageController(
      viewportFraction:
          widget.viewportFraction, // Viewport-Fraction beibehalten
      initialPage: _currentPage, // Starte in der Mitte
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(page % widget.strategies.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              scrollBehavior: AppScrollBehavior(),
              physics: const PageScrollPhysics(),
              itemBuilder: (context, index) {
                final actualIndex = index % widget.strategies.length;
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: StrategyCard(
                        strategy: widget.strategies[actualIndex],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppConfig.layout.spacingMedium),
          child: _buildPageIndicator(),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.strategies.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage % widget.strategies.length == index
                ? AppConfig.colors.primary
                : AppConfig.colors.textSecondary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
