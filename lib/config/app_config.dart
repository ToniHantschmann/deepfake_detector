import 'package:flutter/material.dart';
import 'package:deepfake_detector/config/localization/app_locale.dart';
import 'package:deepfake_detector/config/localization/english_strings.dart';
import 'package:deepfake_detector/config/localization/german_strings.dart';
import 'package:deepfake_detector/config/localization/string_types.dart';

class AppConfig {
  // Singleton-Pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static const colors = AppColors();
  static const layout = AppLayout();
  static const animation = AppAnimation();
  static const timing = AppTiming();
  static const video = AppVideo();
  static const textStyles = AppTextStyles();

  // Localization
  static AppStrings getStrings(AppLocale locale) {
    switch (locale) {
      case AppLocale.de:
        return const GermanStrings();
      case AppLocale.en:
        return const EnglishStrings();
    }
  }
}

class AppColors {
  const AppColors();

  // Primary Colors
  final Color primary = Colors.blue;
  final Color secondary = Colors.green;
  final Color error = Colors.red;
  final Color success = const Color(0xFF064E3B); // Dark Green
  final Color warning = Colors.orange;

  // Background Colors
  final Color background = const Color(0xFF171717);
  final Color backgroundDark = Colors.black;
  final Color backgroundLight = const Color(0xFF262626);
  final Color cardBackground = const Color(0xFF1F1F1F);
  final Color overlayBackground = const Color(0xFF1A1A1A);

  // Text Colors
  final Color textPrimary = Colors.white;
  final Color textSecondary = Colors.grey;
  final Color textDisabled = const Color(0xFF666666);

  // Border Colors
  final Color border = const Color(0xFF333333);
  final Color borderHighlight = Colors.blue;
  final Color pinBorder = const Color(0xFF404040);

  // Video Player Colors
  final Color videoOverlay = Colors.black54;
  final Color videoProgress = Colors.blue;
  final Color videoBuffer = Colors.grey;

  // Status Colors
  final Color correctAnswer = const Color(0xFF064E3B);
  final Color wrongAnswer = const Color(0xFF7F1D1D);

  // Number Pad Colors
  final Color numberPadButton = const Color(0xFF262626);
  final Color numberPadButtonPressed = const Color(0xFF404040);
  final Color numberPadText = Colors.white;
}

class AppLayout {
  const AppLayout();

  // Screen Padding
  final double screenPaddingHorizontal = 32.0;
  final double screenPaddingVertical = 24.0;

  // Content Spacing
  final double spacingSmall = 8.0;
  final double spacingMedium = 16.0;
  final double spacingLarge = 24.0;
  final double spacingXLarge = 32.0;

  // Card Layout
  final double cardRadius = 12.0;
  final double cardPadding = 16.0;
  final double cardElevation = 4.0;

  // Button Sizes
  final double buttonHeight = 52.0;
  final double buttonRadius = 8.0;
  final double buttonPadding = 16.0;

  // Video Player
  final double videoControlSize = 48.0;
  final double videoProgressHeight = 4.0;
  final double videoThumbnailAspectRatio = 16 / 9;

  // Navigation
  final double navigationIconSize = 56.0;
  final double navigationPadding = 16.0;

  // Progress Bar
  final double progressBarHeight = 4.0;
  final double progressBarWidth = 200.0;

  // Overlay Layout
  final double overlayWidth = 400.0;
  final double overlayMinHeight = 500.0;
  final double overlayMaxHeight = 600.0;
  final double overlayRadius = 16.0;
  final double overlayPadding = 24.0;
  final double overlayHeaderHeight = 60.0;
  final double overlayFooterHeight = 80.0;

  // PIN Display
  final double pinDigitSize = 48.0;
  final double pinDigitSpacing = 8.0;
  final double pinDigitBorderWidth = 2.0;
  final double pinDigitRadius = 8.0;
  final double pinDisplayHeight = 64.0;
  final double pinDisplaySpacing = 16.0;

  // Number Pad
  final double numberPadButtonSize = 64.0;
  final double numberPadSpacing = 16.0;
  final double numberPadMargin = 24.0;
  final double numberPadIconSize = 24.0;
  final double numberPadFontSize = 24.0;

  // Language Selector
  final double languageButtonHeight = 36.0;
  final double languageButtonWidth = 48.0;
  final double languageButtonRadius = 8.0;
  final double languageButtonSpacing = 8.0;

  // Breakpoints
  final double breakpointMobile = 600.0;
  final double breakpointTablet = 800.0;
  final double breakpointDesktop = 1200.0;
}

class AppAnimation {
  const AppAnimation();

  // Durations
  final Duration fast = const Duration(milliseconds: 200);
  final Duration normal = const Duration(milliseconds: 300);
  final Duration slow = const Duration(milliseconds: 500);

  // Curves
  final Curve standard = Curves.easeInOut;
  final Curve accelerate = Curves.easeIn;
  final Curve decelerate = Curves.easeOut;

  // Overlay Animations
  final Duration overlayEnter = const Duration(milliseconds: 250);
  final Duration overlayExit = const Duration(milliseconds: 200);
  final Curve overlayEnterCurve = Curves.easeOutQuart;
  final Curve overlayExitCurve = Curves.easeInQuart;
  final Duration overlayBackdropFade = const Duration(milliseconds: 200);

  // PIN Input Animations
  final Duration pinInputDuration = const Duration(milliseconds: 150);
  final Duration pinErrorShake = const Duration(milliseconds: 400);
  final Duration pinDeleteDuration = const Duration(milliseconds: 100);
  final Curve pinInputCurve = Curves.easeOutBack;
  final Curve pinErrorCurve = Curves.elasticIn;
  final Curve pinDeleteCurve = Curves.easeInQuad;

  // Number Pad Animations
  final Duration numberPadPressDuration = const Duration(milliseconds: 100);
  final Curve numberPadPressCurve = Curves.easeInOut;
  final Duration numberPadFeedbackDuration = const Duration(milliseconds: 50);

  // Language Change Animation
  final Duration languageChangeDuration = const Duration(milliseconds: 300);
  final Curve languageChangeCurve = Curves.easeInOut;
}

class AppTiming {
  const AppTiming();

  // Timeouts
  final Duration inactivityTimeout = const Duration(seconds: 300);
  final Duration videoBufferingTimeout = const Duration(seconds: 10);
  final Duration loadingTimeout = const Duration(seconds: 5);
  final Duration overlayTimeout = const Duration(seconds: 30);
  final Duration countdownTimeout = const Duration(seconds: 10);

  // Delays
  final Duration pinDisplayDuration = const Duration(seconds: 3);
  final Duration tooltipDuration = const Duration(seconds: 2);
  final Duration splashScreenDuration = const Duration(seconds: 1);
  final Duration pinFeedbackDuration = const Duration(milliseconds: 1500);
  final Duration errorMessageDuration = const Duration(seconds: 3);
}

class AppVideo {
  const AppVideo();

  // Video Player Settings
  final int maxBufferingDuration = 30; // seconds
  final int seekInterval = 10; // seconds
  final int maxVideoDuration = 300; // seconds
  final int minVideoLength = 10; // seconds

  // Quality Settings
  final double minAspectRatio = 16 / 9;
  final int minResolution = 720; // height in pixels
  final int targetBitrate = 2500000; // bits per second
  final double introImageAspectRatio = 4 / 3;
}

class AppTextStyles {
  const AppTextStyles();

  // Headings
  final TextStyle h1 = const TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final TextStyle h3 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Body Text
  final TextStyle bodyLarge = const TextStyle(
    fontSize: 24,
    color: Colors.white,
    height: 1.5,
  );

  final TextStyle bodyMedium = const TextStyle(
    fontSize: 22,
    color: Colors.white,
    height: 1.5,
  );

  final TextStyle bodySmall = const TextStyle(
    fontSize: 20,
    color: Colors.white,
    height: 1.5,
  );

  // Button Text
  final TextStyle buttonLarge = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  final TextStyle buttonMedium = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Overlay Text
  final TextStyle overlayTitle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final TextStyle overlaySubtitle = const TextStyle(
    fontSize: 20,
    color: Colors.grey,
    height: 1.5,
  );

  // PIN Display
  final TextStyle pinDigit = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final TextStyle pinLabel = const TextStyle(
    fontSize: 18,
    color: Colors.grey,
  );

  // Number Pad
  final TextStyle numberPadButton = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Language Selector
  final TextStyle languageButton = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Caption Text
  final TextStyle caption = const TextStyle(
    fontSize: 18,
    color: Colors.grey,
    height: 1.4,
  );
}
