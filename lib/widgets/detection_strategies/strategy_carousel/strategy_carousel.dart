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
  // Dritter Parameter für die vorherige Strategie-ID
  final Function(int, String, String?)? onPageChanged;
  final Set<String> viewedStrategyIds;

  const StrategyCarousel({
    Key? key,
    required this.strategies,
    this.viewportFraction = 0.4,
    this.onPageChanged,
    required this.viewedStrategyIds,
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

    // Generate a random index within the number of strategies
    final random = Random();
    final randomIndex = random.nextInt(widget.strategies.length);

    // Calculate the initial page as a multiple of the strategy count plus the random index
    _currentPage = widget.strategies.length * _baseMultiplier + randomIndex;

    // Initialize the PageController with the correct initial page
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: _currentPage,
    );

    // Correct the position and trigger the animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        setState(() {
          // Force rebuild to apply initial scaling
        });

        // Wir markieren die initiale Strategie nicht mehr sofort als angesehen
        // Erst beim Wechsel zu einer anderen Strategie wird sie als angesehen markiert
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    // ID der aktuellen Strategie bestimmen, bevor wir zur neuen wechseln
    final int currentIdx = _currentPage % widget.strategies.length;
    final String currentStrategyId = widget.strategies[currentIdx].id;

    // ID der aktuellen Strategie bestimmen, bevor wir zur neuen wechseln
    final int currentIdx = _currentPage % widget.strategies.length;
    final String? currentStrategyId = widget.strategies[currentIdx].id;

    // Seite aktualisieren
    setState(() {
      _currentPage = page;
    });

    // Die aktuelle Strategie-ID (die jetzt die vorherige ist) an den Callback übergeben
    _notifyPageChanged(page, currentStrategyId);
  }

  void _notifyPageChanged(int page, String? previousStrategyId) {
    if (widget.onPageChanged != null) {
      final actualIndex = page % widget.strategies.length;
      final strategyId = widget.strategies[actualIndex].id;

      // Wenn sich die Strategie geändert hat (wenn die IDs unterschiedlich sind),
      // übergeben wir die vorherige ID, sonst null
      final String? prevId =
          (previousStrategyId != null && previousStrategyId != strategyId)
              ? previousStrategyId
              : null;

      widget.onPageChanged!(actualIndex, strategyId, prevId);
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
                final strategy = widget.strategies[actualIndex];
                final hasBeenViewed =
                    widget.viewedStrategyIds.contains(strategy.id);

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
                          strategy: strategy,
                          hasBeenViewed: hasBeenViewed,
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
