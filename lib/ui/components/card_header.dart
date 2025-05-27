import 'package:flutter/material.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';

/// A header widget with optional leading/trailing icons, title and subtitle.
class CardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (leading != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: leading,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.titleLarge
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: DesignSystem.bodyMedium
                      .copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
