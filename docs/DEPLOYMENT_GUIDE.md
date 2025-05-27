# Guide de Déploiement - Ariba

## Vue d'Ensemble

Ce guide détaille les processus de build, de déploiement et de distribution de l'application Ariba sur les différentes plateformes supportées.

## Prérequis

### Outils Requis
- **Flutter SDK** : Version 3.0 ou supérieure
- **Dart SDK** : Version 2.17 ou supérieure
- **Android Studio** : Avec Android SDK et outils de build
- **Xcode** : Version 13+ (pour iOS/macOS)
- **Visual Studio** : Avec C++ tools (pour Windows)
- **Git** : Pour le contrôle de version

### Comptes Développeur
- **Google Play Console** : Pour la distribution Android
- **Apple Developer Program** : Pour iOS/macOS ($99/an)
- **Microsoft Partner Center** : Pour Windows Store (optionnel)

### Certificats et Clés
- **Android** : Keystore de signature
- **iOS** : Certificats de développement et distribution
- **Code Signing** : Configuration des identités

## Configuration de l'Environnement

### Variables d'Environnement
```bash
# Exemple de fichier .env
FLUTTER_ROOT=/path/to/flutter
ANDROID_SDK_ROOT=/path/to/android-sdk
JAVA_HOME=/path/to/java

# Clés API (production)
API_BASE_URL=https://api.ariba-app.com
ANALYTICS_KEY=your_analytics_key
SENTRY_DSN=your_sentry_dsn
```

### Configuration Flutter
```bash
# Vérifier la configuration
flutter doctor -v

# Configuration des canaux
flutter channel stable
flutter upgrade

# Activer les plateformes
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

## Build Android

### Configuration Gradle

#### build.gradle (Module: app)
```gradle
android {
    namespace 'com.ariba.flashcards'
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.ariba.flashcards"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        
        multiDexEnabled true
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
            minifyEnabled false
        }
    }
}
```

#### key.properties
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../ariba-release-key.jks
```

### Génération du Keystore
```bash
# Créer un nouveau keystore
keytool -genkey -v -keystore ariba-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ariba

# Vérifier le keystore
keytool -list -v -keystore ariba-release-key.jks -alias ariba
```

### Build Commands

#### APK Debug
```bash
flutter build apk --debug
# Sortie: build/app/outputs/flutter-apk/app-debug.apk
```

#### APK Release
```bash
flutter build apk --release
# Sortie: build/app/outputs/flutter-apk/app-release.apk
```

#### App Bundle (Recommandé pour Play Store)
```bash
flutter build appbundle --release
# Sortie: build/app/outputs/bundle/release/app-release.aab
```

#### Build avec Profiling
```bash
flutter build apk --profile
flutter build appbundle --profile
```

### Optimisations Android

#### ProGuard Rules (proguard-rules.pro)
```proguard
# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Drift Database
-keep class drift.** { *; }
-keep class **$Tables { *; }

# Provider
-keep class **ViewModel { *; }
-keep class **Provider { *; }
```

## Build iOS

### Configuration Xcode

#### Info.plist
```xml
<key>CFBundleDisplayName</key>
<string>Ariba</string>
<key>CFBundleIdentifier</key>
<string>com.ariba.flashcards</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>

<!-- Permissions -->
<key>NSCameraUsageDescription</key>
<string>Cette app utilise l'appareil photo pour ajouter des images aux cartes.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Cette app utilise le microphone pour enregistrer de l'audio.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette app accède à la galerie photo pour ajouter des images aux cartes.</string>
```

#### Signing & Capabilities
1. **Ouvrir ios/Runner.xcworkspace** dans Xcode
2. **Sélectionner Runner** dans le navigateur
3. **Onglet Signing & Capabilities**
4. **Team** : Sélectionner votre équipe de développement
5. **Bundle Identifier** : com.ariba.flashcards

### Build Commands iOS

#### Debug
```bash
flutter build ios --debug
```

#### Release
```bash
flutter build ios --release
```

#### Archive pour App Store
```bash
flutter build ipa --release
# Sortie: build/ios/ipa/ariba.ipa
```

### Déploiement App Store

#### Avec Xcode
1. **Ouvrir le workspace** ios/Runner.xcworkspace
2. **Product → Archive**
3. **Window → Organizer**
4. **Distribute App → App Store Connect**

#### Avec Transporter
1. **Télécharger Transporter** depuis l'App Store
2. **Glisser le fichier .ipa**
3. **Deliver** vers App Store Connect

## Build Web

### Configuration Web

#### index.html
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Ariba - Application de cartes flash intelligente">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Ariba">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>Ariba</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script>
    window.addEventListener('load', function(ev) {
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: null,
        }
      }).then(function(engineInitializer) {
        return engineInitializer.initializeEngine();
      }).then(function(appRunner) {
        return appRunner.runApp();
      });
    });
  </script>
</body>
</html>
```

#### manifest.json
```json
{
  "name": "Ariba",
  "short_name": "Ariba",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Application de cartes flash intelligente",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Build Commands Web

#### Debug
```bash
flutter build web --debug
```

#### Release
```bash
flutter build web --release
# Sortie: build/web/
```

#### Avec optimisations
```bash
flutter build web --release --web-renderer canvaskit --tree-shake-icons
```

## Build Desktop

### Windows

#### Configuration
```bash
# Activer Windows desktop
flutter config --enable-windows-desktop

# Vérifier les dépendances
flutter doctor
```

#### Build
```bash
flutter build windows --release
# Sortie: build/windows/runner/Release/
```

#### Création d'un Installer
```bash
# Avec NSIS ou Inno Setup
# Créer un script d'installation
# Inclure les DLLs Visual C++ Redistributable
```

### macOS

#### Configuration Info.plist (macos/Runner/Info.plist)
```xml
<key>CFBundleDisplayName</key>
<string>Ariba</string>
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
<key>NSCameraUsageDescription</key>
<string>Cette app utilise l'appareil photo pour ajouter des images aux cartes.</string>
```

#### Build
```bash
flutter build macos --release
# Sortie: build/macos/Build/Products/Release/ariba.app
```

### Linux

#### Configuration
```bash
# Installer les dépendances
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

#### Build
```bash
flutter build linux --release
# Sortie: build/linux/x64/release/bundle/
```

## CI/CD avec GitHub Actions

### Workflow Configuration (.github/workflows/build.yml)
```yaml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.13.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Setup Android signing
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 --decode > android/app/ariba-release-key.jks
          echo "storeFile=ariba-release-key.jks" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storePassword=${{ secrets.STORE_PASSWORD }}" >> android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Setup iOS signing
        run: |
          # Configuration des certificats et profils de provisioning
          echo "${{ secrets.IOS_CERTIFICATE }}" | base64 --decode > ios_certificate.p12
          echo "${{ secrets.PROVISIONING_PROFILE }}" | base64 --decode > ios_profile.mobileprovision
          
          # Import du certificat
          security create-keychain -p "" build.keychain
          security import ios_certificate.p12 -k build.keychain -P "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" -A
          security list-keychains -s build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "" build.keychain
          
          # Installation du profil
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp ios_profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
      
      - name: Build iOS
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
      
      - name: Upload to TestFlight
        run: |
          xcrun altool --upload-app -f build/ios/ipa/ariba.ipa -u "${{ secrets.APPLE_ID }}" -p "${{ secrets.APPLE_PASSWORD }}"

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Build Web
        run: flutter build web --release --web-renderer canvaskit
      
      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: ariba-app
```

## Distribution

### Google Play Store

#### Configuration Play Console
1. **Créer une application** dans Play Console
2. **Configurer les détails** de l'application
3. **Ajouter les captures d'écran** et descriptions
4. **Configurer le contenu rating**
5. **Définir les pays** de distribution

#### Upload et Publication
```bash
# Build de l'App Bundle
flutter build appbundle --release

# Upload via Play Console ou API
# Créer une release dans la console
# Ajouter les notes de version
# Publier sur les tracks (internal, alpha, beta, production)
```

### Apple App Store

#### App Store Connect
1. **Créer l'app** dans App Store Connect
2. **Configurer les métadonnées**
3. **Ajouter les captures d'écran**
4. **Définir les informations** de prix et disponibilité

#### Processus de Review
1. **Upload via Transporter** ou Xcode
2. **Ajouter à une version** dans App Store Connect
3. **Soumettre pour review**
4. **Répondre aux commentaires** d'Apple si nécessaire

### Distribution Web

#### Firebase Hosting
```bash
# Installation de Firebase CLI
npm install -g firebase-tools

# Login et initialisation
firebase login
firebase init hosting

# Déploiement
flutter build web --release
firebase deploy --only hosting
```

#### Configuration firebase.json
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

## Monitoring et Analytics

### Crash Reporting avec Sentry

#### Configuration
```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kDebugMode ? 'development' : 'production';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

### Analytics avec Firebase

#### Configuration
```dart
// analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
```

## Versioning et Release Notes

### Versioning Sémantique
```
MAJOR.MINOR.PATCH (ex: 1.2.3)
- MAJOR: Changements incompatibles
- MINOR: Nouvelles fonctionnalités compatibles
- PATCH: Corrections de bugs
```

#### pubspec.yaml
```yaml
version: 1.2.3+123  # version+buildNumber
```

### Automation avec Scripts

#### bump_version.sh
```bash
#!/bin/bash
# Script pour incrémenter automatiquement la version

CURRENT_VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')
IFS='.' read -ra VERSION_PARTS <<< "${CURRENT_VERSION%+*}"
BUILD_NUMBER="${CURRENT_VERSION#*+}"

case $1 in
  major)
    NEW_VERSION="$((${VERSION_PARTS[0]} + 1)).0.0+$((BUILD_NUMBER + 1))"
    ;;
  minor)
    NEW_VERSION="${VERSION_PARTS[0]}.$((${VERSION_PARTS[1]} + 1)).0+$((BUILD_NUMBER + 1))"
    ;;
  patch)
    NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$((${VERSION_PARTS[2]} + 1))+$((BUILD_NUMBER + 1))"
    ;;
esac

sed -i "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
echo "Version mise à jour: $NEW_VERSION"
```

## Sécurité

### Protection des Clés API
```dart
// Utilisation de flutter_dotenv
await dotenv.load(fileName: ".env");
final apiKey = dotenv.env['API_KEY'];
```

### Obfuscation du Code
```bash
# Build avec obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info
```

### Certificat Pinning
```dart
// Configuration pour les requêtes HTTP sécurisées
class SecureHttpClient {
  static final dio = Dio();
  
  static void configureCertificatePinning() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        // Vérification du certificat
        return cert.sha1.toString() == 'EXPECTED_SHA1_FINGERPRINT';
      };
      return client;
    };
  }
}
```

Ce guide fournit une approche complète pour déployer l'application Ariba sur toutes les plateformes supportées, en intégrant les meilleures pratiques de sécurité, de monitoring et d'automatisation.
