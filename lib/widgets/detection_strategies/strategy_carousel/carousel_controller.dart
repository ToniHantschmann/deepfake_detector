import 'package:flutter/material.dart';

class CarouselController extends ChangeNotifier {
  final PageController pageController;
  final int itemCount;
  int _currentPage;
  bool _isAnimating = false;

  CarouselController({
    required this.itemCount,
    required int initialPage,
  })  : pageController = PageController(
          viewportFraction: 0.8,
          initialPage: initialPage,
        ),
        _currentPage = initialPage;

  int get currentPage => _currentPage;

  void handleScrollEnd() {
    if (_isAnimating) return;

    final page = pageController.page!.round();
    if (page < itemCount) {
      _isAnimating = true;
      pageController
          .animateToPage(
            page + (itemCount * 100),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => _isAnimating = false);
    } else if (page > itemCount * 200) {
      _isAnimating = true;
      pageController
          .animateToPage(
            page - (itemCount * 100),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => _isAnimating = false);
    }
  }

  void animateToPage(int page) {
    if (_isAnimating) return;
    _isAnimating = true;
    pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) => _isAnimating = false);
  }

  void updateCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
