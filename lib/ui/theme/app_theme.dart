import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Ajout de l'importation
import 'design_system.dart';

class AppTheme {
  static const Color primaryBlueGrey = Color(0xFF607D8B); // Bleu-gris principal
  static const Color accentTurquoise = Color(0xFF00BCD4); // Turquoise vibrant
  static const Color accentCoral = Color(0xFFFF7043); // Corail/Orange
  static const Color accentLime =
      Color(0xFFAEEA00); // Lime pour une touche flashy supplémentaire

  static const Color darkBackground = Color(0xFF121212);
  static const Color lightBackground =
      Color(0xFFFFFFFF); // Ou un blanc cassé comme Color(0xFFF5F5F5);

  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color lightTextSecondary = Color(0xFF757575);

  /// Returns a [ThemeData] configured with Material3, color scheme, typography and components.
  static ThemeData getThemeData({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignSystem.seedColor,
      brightness: brightness,
      primary: DesignSystem.primary,
      secondary: DesignSystem.secondary,
      tertiary: DesignSystem.tertiary,
      error: DesignSystem.error,
    );
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkBackground : colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            DesignSystem.titleLarge.copyWith(color: colorScheme.onSurface),
      ),
      textTheme: TextTheme(
        headlineLarge: DesignSystem.h1.copyWith(color: colorScheme.onSurface),
        headlineMedium: DesignSystem.h2.copyWith(color: colorScheme.onSurface),
        headlineSmall: DesignSystem.h3.copyWith(color: colorScheme.onSurface),
        titleLarge:
            DesignSystem.titleLarge.copyWith(color: colorScheme.onSurface),
        titleMedium:
            DesignSystem.titleMedium.copyWith(color: colorScheme.onSurface),
        bodyLarge:
            DesignSystem.bodyLarge.copyWith(color: colorScheme.onSurface),
        bodyMedium:
            DesignSystem.bodyMedium.copyWith(color: colorScheme.onSurface),
        labelLarge: DesignSystem.bodyMedium
            .copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
        labelMedium: DesignSystem.caption
            .copyWith(color: colorScheme.primary, fontWeight: FontWeight.w500),
        bodySmall:
            DesignSystem.caption.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor:
            colorScheme.onSurface.withAlpha((0.6 * 255).round()),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        elevation: 8,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal,
            ),
        },
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
