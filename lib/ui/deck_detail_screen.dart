import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcards_app/ui/components/icon_button_animated.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';
import 'package:flashcards_app/viewmodels/card_viewmodel.dart';
import 'package:flashcards_app/viewmodels/deck_viewmodel.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:flashcards_app/services/error_service.dart';

class DeckDetailScreen extends StatefulWidget {
  final domain.Deck deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<CardViewModel>().loadCardsForDeck(widget.deck.id);
        } catch (e, st) {
          ErrorService.logError(e, st, context: 'DeckDetailScreen.initState');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardViewModel = context.watch<CardViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.colorScheme.surface.withAlpha(230), // translucent
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          widget.deck.name,
          style: DesignSystem.titleLarge
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        actions: [
          // Add Card
          Tooltip(
            message: 'Ajouter une carte',
            child: IconButtonAnimated(
              icon: Icon(Icons.add_card, color: theme.colorScheme.primary),              onPressed: () async {
                // Navigate using GoRouter to pass domain entities correctly
                context.goNamed('newCard', 
                  pathParameters: {'deckId': widget.deck.id.toString()},
                  extra: widget.deck
                );
              },
            ),
          ),          // Study
          Tooltip(
            message: 'Étudier',
            child: IconButtonAnimated(
              icon: Icon(Icons.bar_chart, color: theme.colorScheme.primary),
              onPressed: () {
                _startStudySession(context);
              },
            ),
          ),
          // Analytics
          Tooltip(
            message: 'Analytiques d\'étude',
            child: IconButtonAnimated(
              icon: Icon(Icons.insights, color: theme.colorScheme.primary),
              onPressed: () {
                context.goNamed('studyAnalytics',
                  pathParameters: {'deckId': widget.deck.id.toString()},
                  extra: widget.deck
                );
              },
            ),
          ),
          // Export
          Tooltip(
            message: 'Exporter le paquet',
            child: IconButtonAnimated(
              icon: Icon(Icons.file_upload, color: theme.colorScheme.primary),
              onPressed: () => _exportDeck(context),
            ),
          ),
          // Delete Deck
          Tooltip(
            message: 'Supprimer le paquet',
            child: IconButtonAnimated(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Supprimer le paquet'),
                    content: const Text(
                        'Cette action supprimera toutes les cartes. Continuer ?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Annuler')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Supprimer')),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await context
                        .read<DeckViewModel>()
                        .deleteDeck(widget.deck.id);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e, st) {
                    ErrorService.logError(e, st,
                        context: 'DeckDetailScreen.deleteDeck');
                    if (mounted) {
                      await ErrorService.showErrorDialog(
                        context,
                        title: 'Erreur',
                        message:
                            'Échec de la suppression du paquet. (${e.runtimeType})',
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        layoutBuilder: (currentChild, previousChildren) => Stack(children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ]),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _buildBodyContent(context, cardViewModel),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          _addNewCard(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _exportDeck(BuildContext context) async {
    if (!mounted) {
      return;
    }

    final deckViewModel = context.read<DeckViewModel>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    NavigatorState? navigator = Navigator.of(context, rootNavigator: true);

    if (deckViewModel.isExporting) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Exportation en cours...')),
      );
      return;
    }

    bool dialogShown = false;
    if (mounted) {
      navigator = Navigator.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Exportation en cours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Préparation de l\'exportation...'),
            ],
          ),
        ),
      );
      dialogShown = true;
    }

    try {
      final filePath = await deckViewModel.exportDeck(widget.deck.id);

      // After await, ensure mounted before interacting with Navigator or ScaffoldMessenger
      if (!mounted) {
        return;
      }

      if (dialogShown && navigator.mounted) {
        navigator.pop();
        dialogShown = false;
      }

      if (filePath != null) {
        if (scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Paquet exporté avec succès'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content:
                  Text(deckViewModel.error ?? "Erreur d'exportation inconnue."),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, st) {
      if (!mounted) {
        return;
      }
      if (dialogShown && navigator.mounted) {
        navigator.pop();
      }
      ErrorService.logError(e, st, context: 'DeckDetailScreen.exportDeck');
      if (scaffoldMessenger.mounted) {
        await ErrorService.showErrorDialog(
          context,
          title: 'Erreur',
          message: 'Échec de l’exportation du paquet. (${e.runtimeType})',
        );
      }
    }
  }
  void _startStudySession(BuildContext context) {
    // Use GoRouter for navigation with domain entities
    context.goNamed('review', 
      pathParameters: {'deckId': widget.deck.id.toString()},
      extra: widget.deck
    );
  }

  Widget _buildBodyContent(BuildContext context, CardViewModel cardViewModel) {
    final theme = Theme.of(context);
    if (cardViewModel.isLoading) {
      return Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (cardViewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Erreur: ${cardViewModel.error}',
                style: DesignSystem.bodyLarge
                    .copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () {
                // Removed async as loadCardsForDeck is Future<void>
                if (mounted) {
                  // Added mounted check
                  context
                      .read<CardViewModel>()
                      .loadCardsForDeck(widget.deck.id);
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (cardViewModel.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 48, color: theme.colorScheme.primary),
            SizedBox(height: 16),
            Text('Aucune carte dans ce paquet',
                style: DesignSystem.bodyLarge
                    .copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Ajoutez votre première carte!',
                style: DesignSystem.bodyMedium
                    .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Padding(
      padding: DesignSystem.spacing.smallPadding,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: cardViewModel.cards.length,
        itemBuilder: (context, index) {
          final card = cardViewModel.cards[index];
          return Card(
            elevation: 2,
            margin: DesignSystem.spacing.tinyPadding.copyWith(bottom: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radius.medium)),
            child: ListTile(
              title: Text(
                _extractTextFromSuperEditorJson(card.frontText) ?? 'Avant non disponible',
                style: DesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _extractTextFromSuperEditorJson(card.backText) ?? 'Arrière non disponible',
                style: DesignSystem.bodyMedium
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
          
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.colorScheme.secondary),
                    tooltip: 'Modifier la carte',                    onPressed: () {
                      // Use GoRouter for navigation with domain entities
                      context.goNamed('editCard', 
                        pathParameters: {'deckId': widget.deck.id.toString()},
                        extra: {
                          'deck': widget.deck,
                          'card': card,
                        }
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    tooltip: 'Supprimer la carte',
                    onPressed: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Supprimer la carte'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette carte ?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Supprimer')),
                          ],
                        ),
                      );
                      if (confirmDelete == true) {
                        try {
                          await cardViewModel.deleteCard(card.id, widget.deck.id);
                          // No need to call loadCardsForDeck, as the view model should update the list
                        } catch (e, st) {
                           ErrorService.logError(e, st, context: 'DeckDetailScreen.deleteCard');
                           if (mounted) { // Check mounted before showing dialog
                            await ErrorService.showErrorDialog(context, title: 'Erreur', message: 'Échec de la suppression de la carte. (${e.runtimeType})');
                           }
                        }
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                // Action si l'utilisateur tape sur la carte (par exemple, afficher les détails complets)
                // Pour l'instant, cela pourrait être une navigation vers un écran de détail de carte si nécessaire
              },
            ),
          );
        },
      ),
    );
  }
  void _addNewCard(BuildContext context) {
    // Use GoRouter for navigation with domain entities
    context.goNamed('newCard', 
      pathParameters: {'deckId': widget.deck.id.toString()},
      extra: widget.deck
    );
  }

  String? _extractTextFromSuperEditorJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map && decoded.containsKey('document')) {
        final nodes = decoded['document']?['nodes'];
        if (nodes is List) {
          final buffer = StringBuffer();
          for (final node in nodes) {
            if (node is Map && node['nodes'] is List) {
              for (final innerNode in node['nodes']) {
                if (innerNode is Map && innerNode['text'] is String) {
                  buffer.write(innerNode['text']);
                }
              }
            }
            buffer.write(' '); // Add space between paragraphs or blocks
          }
          return buffer.toString().trim();
        }
      }
      // Fallback for older Quill format (or simple text if not SuperEditor)
      final List<dynamic> delta = jsonDecode(jsonString);
      if (delta.isNotEmpty && delta.first is Map && delta.first.containsKey('insert')) {
        return delta.map((op) => op['insert'].toString()).join().trim();
      }
    } catch (e) {
      // If JSON parsing fails, it might be plain text
      return jsonString;
    }
    return jsonString; // Fallback if extraction fails
  }
}
