import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';
import 'components/chart_card.dart';

/// DashboardScreen replicates a 2x2 grid of summary cards.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: DesignSystem.titleLarge
              .copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            GestureDetector(
              onTap: () => context.go('/decks'),
              child: const ChartCard(title: 'Asset Security Level'),
            ),
            GestureDetector(
              onTap: () => context.go('/stats'),
              child: const ChartCard(title: 'Threat Monitoring'),
            ),
            GestureDetector(
              onTap: () => context.go('/settings/theme'),
              child: const ChartCard(title: 'OSI Model'),
            ),
            GestureDetector(
              onTap: () => context.go('/quill-test'),
              child: const ChartCard(title: 'Cyber Maturity'),
            ),
          ],
        ),
      ),
    );
  }
}
