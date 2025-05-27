import 'package:flutter/material.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';

/// A card widget representing a deck with title, description and an icon.
class DeckCard extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback onTap;

  const DeckCard({
    super.key,
    required this.title,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.folder_open,
                  size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignSystem.titleLarge
                          .copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description?.isNotEmpty == true
                          ? description!
                          : 'Pas de description',
                      style: DesignSystem.bodyMedium
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
