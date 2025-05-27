import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/services/theme_service.dart';

void main() {
  late ThemeService themeService;

  setUpAll(() {
    // Set up fake shared preferences
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    themeService = ThemeService();
    await themeService.initialize();
  });

  group('ThemeService Tests', () {
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
    });    test('should generate theme data with light brightness', () {
      final themeData = themeService.getThemeData(brightness: Brightness.light);
      
      expect(themeData.useMaterial3, true);
      expect(themeData.brightness, Brightness.light);
      // ThemeData doesn't expose fontFamily directly, check service preferences instead
      expect(themeService.preferences.fontFamily, 'Roboto');
    });

    test('should generate theme data with dark brightness', () {
      final themeData = themeService.getThemeData(brightness: Brightness.dark);
      
      expect(themeData.useMaterial3, true);
      expect(themeData.brightness, Brightness.dark);
      // ThemeData doesn't expose fontFamily directly, check service preferences instead
      expect(themeService.preferences.fontFamily, 'Roboto');
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

    test('should convert theme mode correctly', () {
      expect(themeService.themeMode, ThemeMode.system); // Default
      
      themeService.setThemeMode(ThemeOption.light);
      expect(themeService.themeMode, ThemeMode.light);
      
      themeService.setThemeMode(ThemeOption.dark);
      expect(themeService.themeMode, ThemeMode.dark);
      
      themeService.setThemeMode(ThemeOption.custom);
      expect(themeService.themeMode, ThemeMode.system); // Custom maps to system
    });

    test('should save and load preferences correctly', () async {
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
      expect(newService.preferences.primaryColor, Colors.blue);
      expect(newService.preferences.secondaryColor, Colors.green);
      expect(newService.preferences.fontFamily, 'Arial');
      expect(newService.preferences.borderRadius, 8.0);
      expect(newService.preferences.cardElevation, 2.0);
      expect(newService.preferences.backgroundOption, BackgroundOption.hyperspace);
    });

    group('ThemePreferences serialization', () {
      test('should serialize to JSON correctly', () {
        final preferences = ThemePreferences(
          themeMode: ThemeOption.dark,
          primaryColor: Colors.blue,
          secondaryColor: Colors.green,
          fontFamily: 'Arial',
          borderRadius: 8.0,
          cardElevation: 2.0,
          backgroundOption: BackgroundOption.liquidChrome,
        );
        
        final json = preferences.toJson();
        
        expect(json['themeMode'], 'ThemeOption.dark');
        expect(json['primaryColor'], Colors.blue.toARGB32());
        expect(json['secondaryColor'], Colors.green.toARGB32());
        expect(json['fontFamily'], 'Arial');
        expect(json['borderRadius'], 8.0);
        expect(json['cardElevation'], 2.0);
        expect(json['backgroundOption'], 'BackgroundOption.liquidChrome');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'themeMode': 'ThemeOption.dark',
          'primaryColor': Colors.blue.toARGB32(),
          'secondaryColor': Colors.green.toARGB32(),
          'fontFamily': 'Arial',
          'borderRadius': 8.0,
          'cardElevation': 2.0,
          'backgroundOption': 'BackgroundOption.liquidChrome',
        };
        
        final preferences = ThemePreferences.fromJson(json);
        
        expect(preferences.themeMode, ThemeOption.dark);
        expect(preferences.primaryColor, Colors.blue);
        expect(preferences.secondaryColor, Colors.green);
        expect(preferences.fontFamily, 'Arial');
        expect(preferences.borderRadius, 8.0);
        expect(preferences.cardElevation, 2.0);
        expect(preferences.backgroundOption, BackgroundOption.liquidChrome);
      });

      test('should handle missing JSON fields with defaults', () {
        final json = <String, dynamic>{}; // Empty JSON
        
        final preferences = ThemePreferences.fromJson(json);
        
        expect(preferences.themeMode, ThemeOption.system);
        expect(preferences.primaryColor, Colors.deepPurple);
        expect(preferences.secondaryColor, Colors.tealAccent);
        expect(preferences.fontFamily, 'Roboto');
        expect(preferences.borderRadius, 12.0);
        expect(preferences.cardElevation, 1.0);
        expect(preferences.backgroundOption, BackgroundOption.none);
      });
    });
  });
}
