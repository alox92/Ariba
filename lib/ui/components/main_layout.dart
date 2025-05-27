import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A main layout with a side navigation rail and top app bar
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF1A1A1A) 
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark 
            ? const Color(0xFF2D2D30) 
            : theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'Flashcards App',
          style: TextStyle(
            color: isDark 
                ? Colors.white 
                : theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search, 
              color: isDark 
                  ? Colors.white70 
                  : theme.colorScheme.onPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications, 
              color: isDark 
                  ? Colors.white70 
                  : theme.colorScheme.onPrimary,
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),      body: Row(
        children: [
          NavigationRail(
            selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
            backgroundColor: isDark 
                ? const Color(0xFF2D2D30) 
                : theme.colorScheme.surface,
            unselectedIconTheme: IconThemeData(
              color: isDark 
                  ? Colors.white60 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            selectedIndex: 0, // default selection
            onDestinationSelected: (i) => _onNavSelect(context, i),
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(
                  icon: Icon(Icons.layers), label: Text('Paquets')),
              NavigationRailDestination(
                  icon: Icon(Icons.school), label: Text('Révision')),
              NavigationRailDestination(
                  icon: Icon(Icons.bar_chart), label: Text('Stats')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings), label: Text('Paramètres')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
  void _onNavSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/decks');
        break;
      case 2:
        context.go('/review');
        break;
      case 3:
        context.go('/stats');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
