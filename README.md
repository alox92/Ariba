# Ariba - Application de Cartes Mémoire

Ariba est une application moderne de cartes mémoire (flashcards) développée avec Flutter, utilisant la répétition espacée pour optimiser la mémorisation et l'apprentissage.

## Fonctionnalités

- **Gestion de paquets de cartes** : Créez et organisez vos paquets par thèmes ou sujets
- **Cartes riches en contenu** : Ajoutez du texte, des images et des fichiers audio à vos cartes
- **Répétition espacée** : Algorithme d'apprentissage intelligent qui adapte le planning de révision à votre progression
- **Statistiques détaillées** : Suivez votre progression avec des visualisations graphiques
- **Personnalisation du thème** : Adaptez l'apparence de l'application à vos préférences
- **Optimisations de performance** : Gestion efficace des grandes collections de cartes
- **Import/Export** : Partagez facilement vos collections de cartes (bientôt disponible)

## Améliorations récentes

### Personnalisation des thèmes
- Service `ThemeService` pour gérer les préférences d'apparence
- Écran dédié permettant de changer les couleurs, polices et styles
- Sauvegarde des préférences utilisateur via SharedPreferences

### Optimisations de performance
- Service `PerformanceService` pour gérer efficacement les grandes collections
- Chargement par lots, préchargement intelligent et gestion de cache
- Écran pour configurer les optimisations de performance

## Prérequis techniques

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

## Installation

1. Clonez ce dépôt
2. Exécutez `flutter pub get` pour installer les dépendances
3. Lancez l'application avec `flutter run`

## Structure du projet

- `lib/data/` : Modèles de données, tables et base de données
- `lib/domain/` : Couche domaine et interfaces des repositories
- `lib/services/` : Services applicatifs (thème, performance, médias, etc.)
- `lib/ui/` : Interfaces utilisateur et widgets
- `lib/viewmodels/` : ViewModels pour la logique de présentation

## Dépendances principales

- **drift** : ORM SQL pour Flutter/Dart
- **provider** : Gestion d'état
- **flutter_quill** : Éditeur de texte riche
- **path_provider** : Gestion des chemins de fichiers
- **fl_chart** : Visualisations graphiques
- **shared_preferences** : Stockage local des préférences
