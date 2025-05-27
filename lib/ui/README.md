# Couche UI

Cette couche contient l'interface utilisateur de l'application.

## Écrans
- Écran d'accueil (liste des decks)
- Écran de révision des cartes
- Écran d'édition des cartes
- Écran des statistiques
- Écran des paramètres

## Backlog de tickets
1. Build & navigation
   - Corriger les appels `Navigator.pop` et `Navigator.push` pour garantir l’ouverture et la fermeture des écrans.
   - Centraliser la navigation (GoRouter ou Navigator) pour éviter les mix et erreurs de routes.
2. Édition des cartes
   - Vérifier que `EditCardScreen` renvoie `pop(true)` après sauvegarde.
   - Ajouter un bouton 'Modifier' clair sur chaque carte et recharger la liste après retour.
3. Révision des cartes
   - Désactiver temporairement le filtrage SRS pour inclure toutes les cartes.
   - Permettre de tourner la carte, de passer à la suivante, et de relancer la session via un bouton "Recommencer".

## Suivi
Cochez un ticket à la fois et validez par un test manuel ou automatique avant de passer au suivant.