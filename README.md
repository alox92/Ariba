# 📚 Ariba - Application de Cartes Flash Intelligente

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

Ariba est une application mobile moderne de cartes flash développée avec Flutter, conçue pour optimiser l'apprentissage grâce à un système de répétition espacée intelligent et des modes d'étude variés.

## 🌟 Fonctionnalités Principales

### 📖 Modes d'Étude Multiples
- **Quiz Interactif** : Questions à choix multiples avec feedback immédiat
- **Ronde Rapide** : Sessions d'apprentissage chronométrées pour améliorer la rapidité
- **Jeu d'Association** : Associez les termes et définitions de manière ludique
- **Pratique d'Écriture** : Saisissez vos réponses pour un apprentissage actif

### 🧠 Algorithme de Répétition Espacée
- Système d'apprentissage adaptatif basé sur les performances
- Optimisation automatique des intervalles de révision
- Suivi intelligent des progrès d'apprentissage

### 🎨 Interface Moderne
- Design Material 3 avec thèmes personnalisables
- Interface intuitive et accessible
- Support des thèmes clair et sombre
- Animations fluides et transitions élégantes

### 📊 Analytiques et Statistiques
- Tableau de bord des performances détaillées
- Suivi des sessions d'étude
- Métriques de progression par deck
- Historique complet des performances

### 🎵 Contenu Riche
- Support des images dans les cartes
- Intégration audio pour la prononciation
- Formatage de texte avancé
- Médias multiples par carte

### 📱 Fonctionnalités Avancées
- Import/Export de decks de cartes
- Synchronisation et sauvegarde
- Mode hors ligne complet
- Performance optimisée

## 🏗️ Architecture

L'application suit l'architecture **Clean Architecture** avec une séparation claire des responsabilités :

```
lib/
├── domain/          # Logique métier et entités
│   ├── entities/    # Modèles de données
│   ├── usecases/    # Cas d'usage métier
│   └── repositories/ # Interfaces de repositories
├── data/            # Couche d'accès aux données
│   ├── database/    # Base de données Drift
│   ├── repositories/ # Implémentations des repositories
│   └── mappers/     # Conversion entre modèles
├── ui/              # Interface utilisateur
│   ├── screens/     # Écrans de l'application
│   ├── components/  # Composants réutilisables
│   └── themes/      # Thèmes et styles
├── viewmodels/      # ViewModels (Provider)
├── services/        # Services applicatifs
└── core/            # Utilitaires et constantes
```

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK (version 3.8 ou supérieure)
- Dart SDK (version 2.17 ou supérieure)
- Android Studio / VS Code
- Git

### Installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/alox92/Ariba.git
   cd ariba
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer les fichiers de code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

### Configuration de l'environnement de développement

1. **Activer le développement web (optionnel)**
   ```bash
   flutter config --enable-web
   ```

2. **Configurer les émulateurs**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

## 📋 Technologies Utilisées

### Framework et Langage
- **Flutter** : Framework UI multiplateforme
- **Dart** : Langage de programmation

### Gestion d'État
- **Provider** : Gestion d'état réactive et simple

### Base de Données
- **Drift** : ORM SQLite type-safe pour Flutter
- **SQLite** : Base de données locale

### Navigation
- **Go Router** : Routage déclaratif moderne

### Autres Dépendances Clés
- **JSON Annotation** : Sérialisation JSON
- **Equatable** : Comparaison d'objets simplifiée
- **Flutter Launcher Icons** : Génération d'icônes
- **Path Provider** : Accès aux répertoires système

## 🎮 Guide d'Utilisation

### Première Utilisation

1. **Créer votre premier deck**
   - Ouvrez l'application
   - Appuyez sur "Créer un nouveau deck"
   - Donnez un nom et une description à votre deck

2. **Ajouter des cartes**
   - Entrez dans votre deck
   - Appuyez sur "Ajouter une carte"
   - Saisissez la question et la réponse
   - Ajoutez des médias si nécessaire

3. **Commencer à étudier**
   - Sélectionnez un mode d'étude
   - Suivez les instructions à l'écran
   - Consultez vos statistiques après chaque session

### Modes d'Étude Détaillés

#### Quiz Mode
- Questions à choix multiples générées automatiquement
- Feedback immédiat avec explications
- Score et temps de réponse trackés

#### Speed Round
- Sessions chronométrées pour améliorer la rapidité
- Difficulté progressive
- Classements et défis personnels

#### Matching Game
- Associez les termes avec leurs définitions
- Interface de glisser-déposer intuitive
- Scores basés sur la précision et la vitesse

#### Writing Practice
- Saisissez vos réponses manuellement
- Vérification automatique avec tolérance aux fautes
- Amélioration de la mémorisation active

## 🧪 Tests

### Lancer les tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

### Structure des tests

```
test/
├── unit/              # Tests unitaires
│   ├── domain/        # Tests des entités et use cases
│   ├── data/          # Tests des repositories et mappers
│   └── viewmodels/    # Tests des ViewModels
├── widget/            # Tests de widgets
├── integration/       # Tests d'intégration
└── mocks/            # Mocks et helpers de test
```

## 🔧 Développement

### Scripts utiles

```bash
# Génération de code
flutter packages pub run build_runner build

# Génération avec suppression des anciens fichiers
flutter packages pub run build_runner build --delete-conflicting-outputs

# Mode watch pour génération automatique
flutter packages pub run build_runner watch

# Nettoyage
flutter clean && flutter pub get
```

### Convention de nommage

- **Classes** : PascalCase (`DeckViewModel`)
- **Fichiers** : snake_case (`deck_view_model.dart`)
- **Variables** : camelCase (`currentDeck`)
- **Constantes** : SCREAMING_SNAKE_CASE (`DEFAULT_DIFFICULTY`)

## 📦 Build et Déploiement

### Build Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

### Build iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Build Web

```bash
flutter build web --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Guidelines de contribution

- Suivez les conventions de code Dart/Flutter
- Ajoutez des tests pour les nouvelles fonctionnalités
- Mettez à jour la documentation si nécessaire
- Assurez-vous que tous les tests passent

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Support et Contact

- **Issues** : [GitHub Issues](https://github.com/yourusername/ariba/issues)
- **Documentation** : [Wiki du projet](https://github.com/yourusername/ariba/wiki)
- **Email** : support@ariba-app.com

## 🙏 Remerciements

- Équipe Flutter pour le framework exceptionnel
- Communauté open source pour les packages utilisés
- Beta testeurs pour leurs retours précieux

---

⭐ **N'hésitez pas à donner une étoile au projet si vous l'aimez !**
- **fl_chart** : Visualisations graphiques
- **shared_preferences** : Stockage local des préférences
