// lib/config/app_config.dart

import 'package:flutter/material.dart';

class AppConfig {
  // Singleton-Pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Color Constants
  static const colors = AppColors();

  // Layout Constants
  static const layout = AppLayout();

  // Animation Constants
  static const animation = AppAnimation();

  // Time Constants
  static const timing = AppTiming();

  // Video Constants
  static const video = AppVideo();

  // Text Style Constants
  static const textStyles = AppTextStyles();
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

  // Text Colors
  final Color textPrimary = Colors.white;
  final Color textSecondary = Colors.grey;
  final Color textDisabled = const Color(0xFF666666);

  // Border Colors
  final Color border = const Color(0xFF333333);
  final Color borderHighlight = Colors.blue;

  // Video Player Colors
  final Color videoOverlay = Colors.black54;
  final Color videoProgress = Colors.blue;
  final Color videoBuffer = Colors.grey;

  // Status Colors
  final Color correctAnswer = const Color(0xFF064E3B);
  final Color wrongAnswer = const Color(0xFF7F1D1D);
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
}

class AppTiming {
  const AppTiming();

  // Timeouts
  final Duration inactivityTimeout = const Duration(seconds: 15);
  final Duration videoBufferingTimeout = const Duration(seconds: 10);
  final Duration loadingTimeout = const Duration(seconds: 5);

  // Delays
  final Duration pinDisplayDuration = const Duration(seconds: 3);
  final Duration tooltipDuration = const Duration(seconds: 2);
  final Duration splashScreenDuration = const Duration(seconds: 1);
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
}

class AppTextStyles {
  const AppTextStyles();

  // Headings
  final TextStyle h1 = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  final TextStyle h2 = const TextStyle(
    fontSize: 32,
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
    fontSize: 18,
    color: Colors.white,
    height: 1.5,
  );

  final TextStyle bodyMedium = const TextStyle(
    fontSize: 16,
    color: Colors.white,
    height: 1.5,
  );

  final TextStyle bodySmall = const TextStyle(
    fontSize: 14,
    color: Colors.white,
    height: 1.5,
  );

  // Button Text
  final TextStyle buttonLarge = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  final TextStyle buttonMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Caption Text
  final TextStyle caption = const TextStyle(
    fontSize: 12,
    color: Colors.grey,
    height: 1.4,
  );
}
