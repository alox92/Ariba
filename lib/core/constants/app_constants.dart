/// Constantes globales de l'application
class AppConstants {
  // Nom de l'application
  static const String appName = 'Flashcards App';
  static const String appVersion = '1.0.0';
  
  // Base de données
  static const String databaseName = 'flashcards_database.db';
  static const int databaseVersion = 1;
  
  // Valeurs par défaut pour l'algorithme SM-2
  static const double defaultEasinessFactor = 2.5;
  static const int defaultInterval = 1;
  static const int maxEasinessFactor = 4;
  static const double minEasinessFactor = 1.3;
  
  // Limites de l'application
  static const int maxTagsPerCard = 10;
  static const int maxCardTitleLength = 200;
  static const int maxDeckNameLength = 100;
  static const int maxDeckDescriptionLength = 500;
  
  // Chemins des assets
  static const String assetsPath = 'assets';
  static const String animationsPath = '$assetsPath/animations';
  static const String imagesPath = '$assetsPath/images';
  static const String soundsPath = '$assetsPath/sounds';
  
  // Clés pour SharedPreferences
  static const String firstLaunchKey = 'first_launch';
  static const String themePreferenceKey = 'theme_preference';
  static const String languagePreferenceKey = 'language_preference';
  static const String performancePreferenceKey = 'performance_preference';
  
  // Routes
  static const String homeRoute = '/';
  static const String deckDetailRoute = '/deck';
  static const String editCardRoute = '/edit-card';
  static const String reviewRoute = '/review';
  static const String statsRoute = '/stats';
  static const String settingsRoute = '/settings';
  static const String onboardingRoute = '/onboarding';
  
  // Extensions de fichiers supportées
  static const List<String> supportedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
  static const List<String> supportedAudioExtensions = [
    'mp3', 'wav', 'aac', 'ogg', 'm4a'
  ];
  
  // Paramètres d'export/import
  static const String exportFileExtension = '.json';
  static const String backupFileExtension = '.backup';
  
  // Animation durées
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
