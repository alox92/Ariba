import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/services/theme_service.dart';

void main() {
  group('ThemePreferences Tests', () {
    test('should create default preferences', () {
      // Act
      final preferences = ThemePreferences();
      
      // Assert
      expect(preferences.themeMode, ThemeOption.system);
      expect(preferences.primaryColor, Colors.deepPurple);
      expect(preferences.secondaryColor, Colors.tealAccent);
      expect(preferences.fontFamily, 'Roboto');
      expect(preferences.borderRadius, 12.0);
      expect(preferences.cardElevation, 1.0);
      expect(preferences.backgroundOption, BackgroundOption.none);
    });

    test('should create preferences with custom values', () {
      // Act
      final preferences = ThemePreferences(
        themeMode: ThemeOption.dark,
        primaryColor: Colors.blue,
        secondaryColor: Colors.red,
        fontFamily: 'Arial',
        borderRadius: 16.0,
        cardElevation: 3.0,
        backgroundOption: BackgroundOption.liquidChrome,
      );
      
      // Assert
      expect(preferences.themeMode, ThemeOption.dark);
      expect(preferences.primaryColor, Colors.blue);
      expect(preferences.secondaryColor, Colors.red);
      expect(preferences.fontFamily, 'Arial');
      expect(preferences.borderRadius, 16.0);
      expect(preferences.cardElevation, 3.0);
      expect(preferences.backgroundOption, BackgroundOption.liquidChrome);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final preferences = ThemePreferences(
        themeMode: ThemeOption.light,
        primaryColor: Colors.green,
        secondaryColor: Colors.orange,
        fontFamily: 'Arial',
        borderRadius: 16.0,
        cardElevation: 3.0,
        backgroundOption: BackgroundOption.hyperspace,
      );
      
      // Act
      final json = preferences.toJson();
      
      // Assert
      expect(json['themeMode'], 'ThemeOption.light');
      expect(json['primaryColor'], Colors.green.toARGB32());
      expect(json['secondaryColor'], Colors.orange.toARGB32());
      expect(json['fontFamily'], 'Arial');
      expect(json['borderRadius'], 16.0);
      expect(json['cardElevation'], 3.0);
      expect(json['backgroundOption'], 'BackgroundOption.hyperspace');
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'themeMode': 'ThemeOption.dark',
        'primaryColor': Colors.blue.toARGB32(),
        'secondaryColor': Colors.red.toARGB32(),
        'fontFamily': 'Montserrat',
        'borderRadius': 8.0,
        'cardElevation': 2.0,
        'backgroundOption': 'BackgroundOption.liquidChrome',
      };
      
      // Act
      final preferences = ThemePreferences.fromJson(json);
      
      // Assert
      expect(preferences.themeMode, ThemeOption.dark);
      expect(preferences.primaryColor.toARGB32(), Colors.blue.toARGB32());
      expect(preferences.secondaryColor.toARGB32(), Colors.red.toARGB32());
      expect(preferences.fontFamily, 'Montserrat');
      expect(preferences.borderRadius, 8.0);
      expect(preferences.cardElevation, 2.0);
      expect(preferences.backgroundOption, BackgroundOption.liquidChrome);
    });

    test('should handle invalid JSON gracefully', () {
      // Arrange
      final json = {
        'themeMode': 'InvalidTheme',
        'primaryColor': 'invalid',
        'secondaryColor': null,
        'fontFamily': null,
        'borderRadius': 'invalid',
        'cardElevation': null,
        'backgroundOption': 'InvalidBackground',
      };
      
      // Act
      final preferences = ThemePreferences.fromJson(json);
      
      // Assert
      expect(preferences.themeMode, ThemeOption.system);
      expect(preferences.primaryColor, Colors.deepPurple);
      expect(preferences.secondaryColor, Colors.tealAccent);
      expect(preferences.fontFamily, 'Roboto');
      expect(preferences.borderRadius, 12.0);
      expect(preferences.cardElevation, 1.0);
      expect(preferences.backgroundOption, BackgroundOption.none);
    });

    test('should copy with updated values', () {
      // Arrange
      final original = ThemePreferences();
      
      // Act
      final updated = original.copyWith(
        themeMode: ThemeOption.dark,
        primaryColor: Colors.purple,
        fontFamily: 'Times',
      );
      
      // Assert
      expect(updated.themeMode, ThemeOption.dark);
      expect(updated.primaryColor, Colors.purple);
      expect(updated.fontFamily, 'Times');
      // Should keep original values for non-updated fields
      expect(updated.secondaryColor, original.secondaryColor);
      expect(updated.borderRadius, original.borderRadius);
      expect(updated.cardElevation, original.cardElevation);
      expect(updated.backgroundOption, original.backgroundOption);
    });
  });

  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUp(() async {
      // Set up fresh mock shared preferences for each test
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
      await themeService.initialize();
    });

    test('should initialize with default preferences', () {
      expect(themeService.preferences.themeMode, ThemeOption.system);
      expect(themeService.preferences.primaryColor, Colors.deepPurple);
      expect(themeService.preferences.secondaryColor, Colors.tealAccent);
      expect(themeService.preferences.fontFamily, 'Roboto');
      expect(themeService.preferences.borderRadius, 12.0);
      expect(themeService.preferences.cardElevation, 1.0);
      expect(themeService.preferences.backgroundOption, BackgroundOption.none);
    });

    test('should update theme mode', () async {
      await themeService.setThemeMode(ThemeOption.dark);
      
      expect(themeService.preferences.themeMode, ThemeOption.dark);
      expect(themeService.themeMode, ThemeMode.dark);
    });

    test('should update primary color', () async {
      await themeService.setPrimaryColor(Colors.blue);
      
      expect(themeService.preferences.primaryColor, Colors.blue);
    });

    test('should update secondary color', () async {
      await themeService.setSecondaryColor(Colors.green);
      
      expect(themeService.preferences.secondaryColor, Colors.green);
    });

    test('should update font family', () async {
      await themeService.setFontFamily('Arial');
      
      expect(themeService.preferences.fontFamily, 'Arial');
    });

    test('should update border radius', () async {
      await themeService.setBorderRadius(8.0);
      
      expect(themeService.preferences.borderRadius, 8.0);
    });

    test('should update card elevation', () async {
      await themeService.setCardElevation(2.0);
      
      expect(themeService.preferences.cardElevation, 2.0);
    });

    test('should update background option', () async {
      await themeService.setBackgroundOption(BackgroundOption.liquidChrome);
      
      expect(themeService.preferences.backgroundOption, BackgroundOption.liquidChrome);
    });

    test('should generate valid theme data', () {
      final lightTheme = themeService.getThemeData(brightness: Brightness.light);
      final darkTheme = themeService.getThemeData(brightness: Brightness.dark);
      
      expect(lightTheme.useMaterial3, true);
      expect(lightTheme.brightness, Brightness.light);
      
      expect(darkTheme.useMaterial3, true);
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('should generate light theme data correctly', () {
      // Act
      final themeData = themeService.getThemeData(brightness: Brightness.light);
      
      // Assert
      expect(themeData.brightness, Brightness.light);
      expect(themeData.useMaterial3, isTrue);
      expect(themeData.cardTheme.elevation, 1.0);
      expect(themeData.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should generate dark theme data correctly', () {
      // Act
      final themeData = themeService.getThemeData(brightness: Brightness.dark);
      
      // Assert
      expect(themeData.brightness, Brightness.dark);
      expect(themeData.useMaterial3, isTrue);
      expect(themeData.cardTheme.elevation, 1.0);
    });    test('should handle different font families', () async {      // Arrange
      await themeService.setFontFamily('Arial');
      
      // Act
      themeService.getThemeData(brightness: Brightness.light);
      
      // Assert
      // Check service preferences since ThemeData doesn't expose fontFamily directly
      expect(themeService.preferences.fontFamily, 'Arial');
    });

    test('should handle different border radius', () async {
      // Arrange
      await themeService.setBorderRadius(20.0);
      
      // Act
      final themeData = themeService.getThemeData(brightness: Brightness.light);
      
      // Assert
      final cardShape = themeData.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(20.0));
    });

    test('should handle different card elevation', () async {
      // Arrange
      await themeService.setCardElevation(5.0);
      
      // Act
      final themeData = themeService.getThemeData(brightness: Brightness.light);
      
      // Assert
      expect(themeData.cardTheme.elevation, 5.0);
    });

    test('should reset to defaults', () async {
      // First change some values
      await themeService.setThemeMode(ThemeOption.dark);
      await themeService.setPrimaryColor(Colors.red);
      await themeService.setFontFamily('Arial');
      
      // Reset to defaults
      await themeService.resetToDefaults();
      
      expect(themeService.preferences.themeMode, ThemeOption.system);
      expect(themeService.preferences.primaryColor, Colors.deepPurple);
      expect(themeService.preferences.fontFamily, 'Roboto');
    });

    test('should convert theme mode correctly', () async {
      // Test default
      expect(themeService.themeMode, ThemeMode.system);
      
      // Test light mode
      await themeService.setThemeMode(ThemeOption.light);
      expect(themeService.themeMode, ThemeMode.light);
      
      // Test dark mode
      await themeService.setThemeMode(ThemeOption.dark);
      expect(themeService.themeMode, ThemeMode.dark);
      
      // Test custom mode (maps to system)
      await themeService.setThemeMode(ThemeOption.custom);
      expect(themeService.themeMode, ThemeMode.system);
    });    test('should save and load preferences correctly', () async {
      // Set custom preferences
      await themeService.setThemeMode(ThemeOption.dark);
      await themeService.setPrimaryColor(Colors.blue);
      await themeService.setSecondaryColor(Colors.green);
      await themeService.setFontFamily('Arial');
      await themeService.setBorderRadius(8.0);
      await themeService.setCardElevation(2.0);
      await themeService.setBackgroundOption(BackgroundOption.hyperspace);
      
      // Create new service instance and load
      final newService = ThemeService();
      await newService.initialize();
      
      expect(newService.preferences.themeMode, ThemeOption.dark);
      // Compare color values instead of expecting exact type match
      expect(newService.preferences.primaryColor.toARGB32(), Colors.blue.toARGB32());
      expect(newService.preferences.secondaryColor.toARGB32(), Colors.green.toARGB32());
      expect(newService.preferences.fontFamily, 'Arial');
      expect(newService.preferences.borderRadius, 8.0);
      expect(newService.preferences.cardElevation, 2.0);
      expect(newService.preferences.backgroundOption, BackgroundOption.hyperspace);
    });

    group('Enums', () {
      test('ThemeOption should have all expected values', () {
        expect(ThemeOption.values, hasLength(4));
        expect(ThemeOption.values, contains(ThemeOption.light));
        expect(ThemeOption.values, contains(ThemeOption.dark));
        expect(ThemeOption.values, contains(ThemeOption.system));
        expect(ThemeOption.values, contains(ThemeOption.custom));
      });

      test('BackgroundOption should have all expected values', () {
        expect(BackgroundOption.values, hasLength(5));
        expect(BackgroundOption.values, contains(BackgroundOption.none));
        expect(BackgroundOption.values, contains(BackgroundOption.liquidChrome));
        expect(BackgroundOption.values, contains(BackgroundOption.hyperspace));
        expect(BackgroundOption.values, contains(BackgroundOption.waveMath));
        expect(BackgroundOption.values, contains(BackgroundOption.infiniteFractal));
      });
    });
  });
}
