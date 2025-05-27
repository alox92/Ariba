import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { light, dark, system, custom }

// Add background options
enum BackgroundOption {
  none,
  liquidChrome,
  hyperspace,
  waveMath,
  infiniteFractal
}

class ThemePreferences {
  final ThemeOption themeMode;
  final Color primaryColor;
  final Color secondaryColor; // Added secondaryColor
  final String fontFamily;
  final double borderRadius;
  final double cardElevation;
  final BackgroundOption backgroundOption; // New field

  ThemePreferences({
    this.themeMode = ThemeOption.system,
    this.primaryColor = Colors.deepPurple,
    this.secondaryColor = Colors.tealAccent, // Added to constructor
    this.fontFamily = 'Roboto',
    this.borderRadius = 12.0,
    this.cardElevation = 1.0,
    this.backgroundOption = BackgroundOption.none, // Default
  });  factory ThemePreferences.fromJson(Map<String, dynamic> json) {    // Helper function to safely parse int from dynamic value
    int? safeParseInt(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }    // Helper function to safely parse double from dynamic value
    double safeParseDouble(dynamic value, double defaultValue) {
      if (value == null) {
        return defaultValue;
      }
      if (value is double) {
        return value;
      }
      if (value is int) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    return ThemePreferences(
      themeMode: ThemeOption.values.firstWhere(
          (e) => e.toString() == json['themeMode'],
          orElse: () => ThemeOption.system),
      primaryColor: () {
        final colorValue = safeParseInt(json['primaryColor']);
        return colorValue != null ? Color(colorValue) : Colors.deepPurple;
      }(),
      secondaryColor: () {
        final colorValue = safeParseInt(json['secondaryColor']);
        return colorValue != null ? Color(colorValue) : Colors.tealAccent;
      }(),
      fontFamily: json['fontFamily'] as String? ?? 'Roboto',
      borderRadius: safeParseDouble(json['borderRadius'], 12.0),
      cardElevation: safeParseDouble(json['cardElevation'], 1.0),
      backgroundOption: BackgroundOption.values.firstWhere(
        (e) => e.toString() == json['backgroundOption'],
        orElse: () => BackgroundOption.none,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.toString(),
      'primaryColor':
          primaryColor.toARGB32(), // Replaced .value with .toARGB32()
      'secondaryColor':
          secondaryColor.toARGB32(), // Replaced .value with .toARGB32()
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
      'cardElevation': cardElevation,
      'backgroundOption': backgroundOption.toString(),
    };
  }

  ThemePreferences copyWith({
    ThemeOption? themeMode,
    Color? primaryColor,
    Color? secondaryColor, // Added to copyWith
    String? fontFamily,
    double? borderRadius,
    double? cardElevation,
    BackgroundOption? backgroundOption,
  }) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor:
          secondaryColor ?? this.secondaryColor, // Added to copyWith
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      backgroundOption: backgroundOption ?? this.backgroundOption,
    );
  }
}

class ThemeService extends ChangeNotifier {
  static const String _prefsKey = 'ariba_theme_preferences';
  late SharedPreferences _prefs;

  ThemePreferences _preferences = ThemePreferences();

  ThemePreferences get preferences => _preferences;

  // Convertir les préférences en ThemeData pour l'application
  ThemeData getThemeData({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _preferences.primaryColor,
      secondary: _preferences.secondaryColor, // Use secondaryColor here
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _preferences.fontFamily,
      cardTheme: CardThemeData(
        elevation: _preferences.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_preferences.borderRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_preferences.borderRadius),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(_preferences.borderRadius + 4.0)),
        elevation: _preferences.cardElevation + 2.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_preferences.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_preferences.borderRadius),
        ),
      )),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  ThemeMode get themeMode {
    switch (_preferences.themeMode) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
      case ThemeOption.custom:
        return ThemeMode.system;
    }
  }

  // Initialiser le service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadPreferences();
  }

  // Charger les préférences depuis SharedPreferences
  Future<void> loadPreferences() async {
    final String? prefsString = _prefs.getString(_prefsKey);
    if (prefsString != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
            Map.castFrom(const JsonDecoder().convert(prefsString)));
        _preferences = ThemePreferences.fromJson(json);
      } catch (e) {
        _preferences = ThemePreferences(); // Valeurs par défaut en cas d'erreur
      }
    }
    notifyListeners();
  }

  // Sauvegarder les préférences dans SharedPreferences
  Future<void> savePreferences() async {
    final String prefsString =
        const JsonEncoder().convert(_preferences.toJson());
    await _prefs.setString(_prefsKey, prefsString);
    notifyListeners();
  }

  // Mettre à jour le mode de thème
  Future<void> setThemeMode(ThemeOption mode) async {
    _preferences = _preferences.copyWith(themeMode: mode);
    await savePreferences();
  }

  // Mettre à jour la couleur primaire
  Future<void> setPrimaryColor(Color color) async {
    _preferences = _preferences.copyWith(primaryColor: color);
    await savePreferences();
  }

  // Mettre à jour la couleur secondaire
  Future<void> setSecondaryColor(Color color) async {
    _preferences = _preferences.copyWith(secondaryColor: color);
    await savePreferences();
  }

  // Mettre à jour la famille de police
  Future<void> setFontFamily(String fontFamily) async {
    _preferences = _preferences.copyWith(fontFamily: fontFamily);
    await savePreferences();
  }

  // Mettre à jour le rayon de bordure
  Future<void> setBorderRadius(double radius) async {
    _preferences = _preferences.copyWith(borderRadius: radius);
    await savePreferences();
  }

  // Mettre à jour l'élévation des cartes
  Future<void> setCardElevation(double elevation) async {
    _preferences = _preferences.copyWith(cardElevation: elevation);
    await savePreferences();
  }

  // Update background option
  Future<void> setBackgroundOption(BackgroundOption option) async {
    _preferences = _preferences.copyWith(backgroundOption: option);
    await savePreferences();
  }

  // Réinitialiser toutes les préférences
  Future<void> resetToDefaults() async {
    _preferences = ThemePreferences();
    await savePreferences();
  }
}
