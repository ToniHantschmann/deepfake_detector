import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../models/strategy_model.dart';
import '../../../config/app_config.dart';
import '../strategy_card.dart';
import 'dart:math';

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
  static const int _baseMultiplier = 100;

  @override
  void initState() {
    super.initState();

    // Generiere einen zufälligen Index innerhalb der Strategieanzahl
    final random = Random();
    final randomIndex = random.nextInt(widget.strategies.length);

    // Berechne die initiale Seite als Vielfaches der Strategieanzahl plus den zufälligen Index
    _currentPage = widget.strategies.length * _baseMultiplier + randomIndex;

    // Initialisiere den PageController mit der korrekten initialen Seite
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _currentPage,
    );

    // Korrigiere die Position und triggere die Animation nach dem ersten Frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        setState(() {
          // Force rebuild to apply initial scaling
        });
      }
    });
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

    // Überprüfe, ob wir uns zu weit vom Basismultiplikator entfernt haben
    final basePosition = widget.strategies.length * _baseMultiplier;
    final offset = (page - basePosition).abs();

    if (offset > widget.strategies.length * 10) {
      // Springe zurück zur Basismultiplikator-Position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          final targetPage = basePosition + (page % widget.strategies.length);
          _pageController.jumpToPage(targetPage);
        }
      });
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
                    } else {
                      // Provide initial scaling before scrolling
                      value = _currentPage.toDouble() - index;
                    }
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    return Transform.scale(
                      scale: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.layout.spacingMedium,
                        ),
                        child: StrategyCard(
                          strategy: widget.strategies[actualIndex],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppConfig.layout.spacingLarge,
            bottom: AppConfig.layout.spacingMedium,
          ),
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
