import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/services/theme_service.dart';

void main() {
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
    });

    group('ThemePreferences serialization', () {
      test('should serialize to JSON correctly', () {
        final preferences = ThemePreferences(
          themeMode: ThemeOption.dark,
          primaryColor: const Color(0xFF2196F3), // Use specific color value
          secondaryColor: const Color(0xFF4CAF50), // Use specific color value
          fontFamily: 'Arial',
          borderRadius: 8.0,
          cardElevation: 2.0,
          backgroundOption: BackgroundOption.liquidChrome,
        );
        
        final json = preferences.toJson();
        
        expect(json['themeMode'], 'ThemeOption.dark');
        expect(json['primaryColor'], 0xFF2196F3);
        expect(json['secondaryColor'], 0xFF4CAF50);
        expect(json['fontFamily'], 'Arial');
        expect(json['borderRadius'], 8.0);
        expect(json['cardElevation'], 2.0);
        expect(json['backgroundOption'], 'BackgroundOption.liquidChrome');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'themeMode': 'ThemeOption.dark',
          'primaryColor': 0xFF2196F3,
          'secondaryColor': 0xFF4CAF50,
          'fontFamily': 'Arial',
          'borderRadius': 8.0,
          'cardElevation': 2.0,
          'backgroundOption': 'BackgroundOption.liquidChrome',
        };
          final preferences = ThemePreferences.fromJson(json);
        
        expect(preferences.themeMode, ThemeOption.dark);
        expect(preferences.primaryColor.toARGB32(), 0xFF2196F3);
        expect(preferences.secondaryColor.toARGB32(), 0xFF4CAF50);
        expect(preferences.fontFamily, 'Arial');
        expect(preferences.borderRadius, 8.0);
        expect(preferences.cardElevation, 2.0);
        expect(preferences.backgroundOption, BackgroundOption.liquidChrome);
      });

      test('should handle missing JSON fields with defaults', () {
        final json = <String, dynamic>{}; // Empty JSON
        
        final preferences = ThemePreferences.fromJson(json);
          expect(preferences.themeMode, ThemeOption.system);
        expect(preferences.primaryColor.toARGB32(), Colors.deepPurple.toARGB32());
        expect(preferences.secondaryColor.toARGB32(), Colors.tealAccent.toARGB32());
        expect(preferences.fontFamily, 'Roboto');
        expect(preferences.borderRadius, 12.0);
        expect(preferences.cardElevation, 1.0);
        expect(preferences.backgroundOption, BackgroundOption.none);
      });
    });
  });
}
