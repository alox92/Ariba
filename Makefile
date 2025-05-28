# Makefile pour Ariba - Application Flutter de cartes flash
# Automatise les tâches courantes de développement

.PHONY: help install build test clean analyze format get deps outdated run-android run-web run-windows

help: ## Affiche cette aide
	@echo "Ariba - Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation et configuration
install: ## Installe les dépendances et génère les fichiers
	flutter pub get
	flutter packages pub run build_runner build --delete-conflicting-outputs

get: ## Met à jour les dépendances
	flutter pub get

deps: ## Affiche les dépendances
	flutter pub deps

outdated: ## Vérifie les packages obsolètes
	flutter pub outdated

# Build et compilation
build: ## Build l'application pour toutes les plateformes
	flutter build apk --release
	flutter build web --release
	flutter build windows --release

build-android: ## Build pour Android uniquement
	flutter build apk --release

build-web: ## Build pour Web uniquement
	flutter build web --release

build-windows: ## Build pour Windows uniquement
	flutter build windows --release

# Tests et qualité
test: ## Lance tous les tests avec couverture
	flutter test --coverage
	@echo "Couverture générée dans coverage/lcov.info"

test-unit: ## Lance uniquement les tests unitaires
	flutter test test/unit/

test-widget: ## Lance uniquement les tests de widgets
	flutter test test/widget/

analyze: ## Analyse statique du code
	flutter analyze

format: ## Formate le code selon les conventions Dart
	dart format lib/ test/

fix: ## Applique les corrections automatiques
	dart fix --apply

# Nettoyage
clean: ## Nettoie le projet
	flutter clean
	flutter pub get

clean-all: ## Nettoyage complet avec cache
	flutter clean
	rm -rf .dart_tool/
	rm -rf build/
	flutter pub get

# Exécution
run-android: ## Lance l'app sur Android
	flutter run -d android

run-web: ## Lance l'app sur le navigateur
	flutter run -d web-server

run-windows: ## Lance l'app sur Windows
	flutter run -d windows

run-debug: ## Lance en mode debug avec hot-reload
	flutter run --debug

# Génération de code
generate: ## Génère les fichiers de code (drift, etc.)
	flutter packages pub run build_runner build --delete-conflicting-outputs

watch: ## Mode watch pour la génération de code
	flutter packages pub run build_runner watch --delete-conflicting-outputs

# Documentation
docs: ## Génère la documentation du code
	dart doc

# Git et versioning
git-clean: ## Nettoie les fichiers git non trackés
	git clean -fd

git-status: ## Affiche le statut git
	git status --porcelain

# Développement
dev: ## Lance l'environnement de développement complet
	make clean
	make install
	make generate
	make analyze
	make test

# Production
release: ## Prépare une release
	make clean
	make install
	make analyze
	make test
	make build
	@echo "Release prête dans build/"

# Métriques
loc: ## Compte les lignes de code
	@find lib/ -name "*.dart" -exec wc -l {} + | tail -1

size: ## Affiche la taille du projet
	@du -sh .
	@echo "Détail des dossiers:"
	@du -sh */ | sort -hr
