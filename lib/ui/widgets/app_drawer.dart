import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:flashcards_app/ui/components/icon_button_animated.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ariba Flashcards',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Une méthode efficace pour apprendre',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(204),
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Accueil'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.pop(context);
                // For global stats
                context.pushNamed('statsGlobal');
              },
            ),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('statsGlobal');
            },
          ),
          const Divider(), // Séparateur visuel
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.palette),
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('themeSettings');
              },
            ),
            title: const Text('Personnalisation du thème'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('themeSettings');
            },
          ),          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.speed),
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('performanceSettings');
              },
            ),
            title: const Text('Optimisations de performance'),
            subtitle: const Text('Pour les grandes collections'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('performanceSettings');
            },
          ),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.school),
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('studyModeSettings');
              },
            ),
            title: const Text('Paramètres d\'étude'),
            subtitle: const Text('Personnaliser les modes d\'étude'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('studyModeSettings');
            },
          ),
          const Divider(),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.import_export),
              onPressed: () {},
            ),
            title: const Text('Importer / Exporter'),
            enabled: false,
            onTap: () {},
          ),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed('quillTest');
              },
            ),
            title: const Text('Test Éditeur Quill'),
            subtitle: const Text('Diagnostic problèmes'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('quillTest');
            },
          ),
          ListTile(
            leading: IconButtonAnimated(
              icon: const Icon(Icons.info),
              onPressed: () => _showAboutDialog(context),
            ),
            title: const Text('À propos'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ariba Flashcards',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2024 Ariba',
      children: const [
        SizedBox(height: 16),
        Text(
          'Une application de cartes mémoire utilisant la répétition espacée pour optimiser la mémorisation.',
        ),
      ],
    );
  }
}
