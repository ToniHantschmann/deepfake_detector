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
  final Function(int, String, String?)?
      onPageChanged; // Aktualisierter Callback mit 3 Parametern
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

    setState(() {
      _currentPage = page;
    });

    if (widget.onPageChanged != null) {
      final actualIndex = page % widget.strategies.length;
      final strategyId = widget.strategies[actualIndex].id;

      // Nur wenn sich die Strategy wirklich geändert hat
      final String? prevId =
          (currentStrategyId != strategyId) ? currentStrategyId : null;

      widget.onPageChanged!(actualIndex, strategyId, prevId);
    }
  }

  void _navigateToPreviousStrategy() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextStrategy() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ScrollConfiguration(
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

              // Navigation Button für vorherige Strategie
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppConfig.colors.backgroundDark.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _navigateToPreviousStrategy,
                    ),
                  ),
                ),
              ),

              // Navigation Button für nächste Strategie
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppConfig.colors.backgroundDark.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _navigateToNextStrategy,
                    ),
                  ),
                ),
              ),
            ],
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
