import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'dart:ui';
import 'package:flashcards_app/ui/components/icon_button_animated.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';
// Removed flutter_animate: static presentation for stability
import 'package:flashcards_app/ui/components/deck_card.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;
import 'package:go_router/go_router.dart';
import 'package:flashcards_app/ui/deck_search_delegate.dart';
// import 'package:flashcards_app/ui/notifications_screen.dart';

import 'package:flashcards_app/viewmodels/deck_viewmodel.dart';
import 'package:flashcards_app/ui/widgets/app_drawer.dart';
import 'package:flashcards_app/ui/components/input_field.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeckViewModel>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Paquets',
          style: DesignSystem.titleLarge
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface
            .withAlpha((0.8 * 255).round()),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButtonAnimated(
            icon: Icon(Icons.file_download, color: theme.colorScheme.primary),
            onPressed: () => _importDeck(context, viewModel),
          ),
          IconButtonAnimated(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: () => _onSearch(context, viewModel),
          ),
          IconButtonAnimated(
            icon: Icon(Icons.notifications, color: theme.colorScheme.primary),
            onPressed: () => _onNotifications(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Paramètres est dans le menu latéral.')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Accès Paramètres (Drawer)'),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeckDialog(context, viewModel),
        tooltip: 'Ajouter un paquet',
        child: Icon(Icons.add, color: theme.colorScheme.onSecondary),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DeckViewModel viewModel) {
    final theme = Theme.of(context);
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final decks = viewModel.decks;
    if (decks.isEmpty) {
      return Center(
        child: Text(
          'Aucun paquet trouvé.\nAppuyez sur + pour en ajouter un !',
          textAlign: TextAlign.center,
          style: DesignSystem.bodyLarge
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: decks.length,
      itemBuilder: (context, i) {
        final deck = decks[i];
        return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 2,
          closedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          closedColor: theme.colorScheme.surface,
          openColor: theme.colorScheme.surface,
          closedBuilder: (context, open) => DeckCard(
            title: deck.name,
            description: deck.description,
            onTap: open,
          ),          openBuilder: (context, action) {
            // Use GoRouter navigation instead of direct instantiation
            context.goNamed('deckDetail', 
              pathParameters: {'deckId': deck.id.toString()},
              extra: deck
            );
            // Return a placeholder that won't be shown due to navigation
            return Container();
          },
        );
      },
    );
  }

  void _showAddDeckDialog(BuildContext dialogContext, DeckViewModel viewModel) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: dialogContext, // Use dialogContext here
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Paquet'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                controller: nameController,
                label: 'Nom du paquet',
                hint: 'Ex: Vocabulaire Espagnol',
                validator: (v) {
                  return (v == null || v.trim().isEmpty)
                      ? 'Le nom est requis'
                      : null;
                }
              ),
              const SizedBox(height: 12),
              InputField(
                controller: descController,
                label: 'Description (optionnel)',
                hint: 'Ex: Chapitres 1-3',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                viewModel.addDeck(
                    nameController.text.trim(), descController.text.trim());
                // Check if the context is still valid before popping
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _importDeck(
      BuildContext context, DeckViewModel viewModel) async {
    if (viewModel.isImporting) {
      return;
    }
    // It's generally safer to check if the widget is still mounted before showing UI elements
    if (!context.mounted) {
      return;
    }
    final snack = ScaffoldMessenger.of(context);
    snack
        .showSnackBar(const SnackBar(content: Text('Importation en cours...')));

    final id = await viewModel.importDeckFromPicker();

    if (!context.mounted) {
      return; // Check again after await
    }
    snack.hideCurrentSnackBar();
    if (id != null) {
      snack.showSnackBar(
          const SnackBar(content: Text('Paquet importé avec succès')));
    } else if (viewModel.error != null) {
      snack.showSnackBar(SnackBar(
          content: Text('Erreur: ${viewModel.error}'),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }
  Future<void> _onSearch(BuildContext context, DeckViewModel viewModel) async {
    // Ensure context is valid before showSearch
    if (!context.mounted) {
      return;
    }
    final domain.Deck? result = await showSearch<domain.Deck?>(
      context: context,
      delegate: DeckSearchDelegate(viewModel.decks),
    );
    if (!context.mounted) {
      return; // Check again after await
    }
    if (result != null) {
      context.pushNamed(
        'deckDetail',
        pathParameters: {'deckId': result.id.toString()},
        extra: result,
      );
    }
  }

  void _onNotifications(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    context.pushNamed('notifications');
  }
}
