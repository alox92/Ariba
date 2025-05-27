import 'package:flutter/material.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;

/// SearchDelegate to search domain.Deck by name.
class DeckSearchDelegate extends SearchDelegate<domain.Deck?> {
  final List<domain.Deck> decks;

  DeckSearchDelegate(this.decks);

  @override
  String get searchFieldLabel => 'Rechercher un paquet';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = decks
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final deck = results[index];        return ListTile(
          title: Text(deck.name),
          subtitle: deck.description.isNotEmpty ? Text(deck.description) : null,
          onTap: () => close(context, deck),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = decks
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final deck = suggestions[index];
        return ListTile(
          title: Text(deck.name),
          onTap: () {
            query = deck.name;
            showResults(context);
          },
        );
      },
    );
  }
}
