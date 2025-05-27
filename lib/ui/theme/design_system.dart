import 'package:flutter/material.dart';

/// Central Design System constants: palette and typography scales
class DesignSystem {
  // Seed color for Material 3
  static const Color seedColor = Color(0xFF6750A4);

  // Custom palette roles (can override parts of generated ColorScheme)
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);

  // Typography scales
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
  );

  // Spacing and Radius
  static const AppSpacing spacing = AppSpacing();
  static const AppRadius radius = AppRadius();
}

class AppSpacing {
  const AppSpacing();
  final double tiny = 4.0;
  final double small = 8.0;
  final double medium = 16.0;
  final double large = 24.0;
  final double extraLarge = 32.0;

  EdgeInsets get tinyPadding => EdgeInsets.all(tiny);
  EdgeInsets get smallPadding => EdgeInsets.all(small);
  EdgeInsets get mediumPadding => EdgeInsets.all(medium);
  EdgeInsets get largePadding => EdgeInsets.all(large);
  EdgeInsets get extraLargePadding => EdgeInsets.all(extraLarge);
}

class AppRadius {
  const AppRadius();
  final double small = 4.0;
  final double medium = 8.0;
  final double large = 16.0;
  final double extraLarge = 24.0;
}
