import 'package:flutter/material.dart';
import 'package:flashcards_app/services/performance_service.dart';
import 'package:flashcards_app/services/media_service.dart'; // Import MediaService
import 'package:go_router/go_router.dart';

class PerformanceSettingsScreen extends StatefulWidget {
  const PerformanceSettingsScreen({super.key});

  @override
  State<PerformanceSettingsScreen> createState() =>
      _PerformanceSettingsScreenState();
}

class _PerformanceSettingsScreenState extends State<PerformanceSettingsScreen> {
  final PerformanceService _performanceService = PerformanceService();
  final MediaService _mediaService = MediaService(); // Instantiate MediaService
  bool _optimizationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _optimizationsEnabled = _performanceService.optimizationEnabled;
  }

  Future<void> _cleanupTempMedia(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    bool dialogShown = false;

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          title: Text('Nettoyage en cours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Nettoyage du cache des médias...'),
            ],
          ),
        );
      },
    );
    dialogShown = true;

    try {
      await _mediaService
          .clearMediaCache(); // Call the actual cache cleaning method

      if (!mounted) {
        return;
      }

      if (dialogShown) {
        navigator.pop();
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Cache des médias nettoyé avec succès.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      if (dialogShown) {
        navigator.pop();
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur lors du nettoyage du cache: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimisations de performance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Activation des optimisations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Optimisations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title:
                        const Text('Activer les optimisations de performance'),
                    subtitle: const Text(
                      'Recommandé pour les grandes collections de cartes',
                    ),
                    value: _optimizationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _optimizationsEnabled = value;
                        _performanceService.setOptimizationEnabled(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Seuils
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seuils de performance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Collection de grande taille'),
                    subtitle: Text(
                      '> ${PerformanceService.kLargeCollectionThreshold} cartes',
                    ),
                    leading: Icon(Icons.line_weight),
                  ),
                  ListTile(
                    title: Text('Collection de très grande taille'),
                    subtitle: Text(
                      '> ${PerformanceService.kVeryLargeCollectionThreshold} cartes',
                    ),
                    leading: Icon(Icons.warning_amber_rounded),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Optimisations actives
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optimisations actives',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  _OptimizationItem(
                    title: 'Chargement par lots',
                    description:
                        'Les cartes sont chargées par groupes pour améliorer les performances',
                    enabled: true,
                  ),
                  Divider(),
                  _OptimizationItem(
                    title: 'Préchargement intelligent',
                    description:
                        'Les médias des prochaines cartes sont préchargés en avance',
                    enabled: true,
                  ),
                  Divider(),
                  _OptimizationItem(
                    title: 'Gestion de mémoire adaptative',
                    description:
                        'La limite de cache est ajustée en fonction de la taille de la collection',
                    enabled: true,
                  ),
                  Divider(),
                  _OptimizationItem(
                    title: 'Nettoyage automatique',
                    description:
                        'Les fichiers temporaires inutilisés sont supprimés après 7 jours',
                    enabled: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),          // Actions manuelles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions manuelles',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Paramètres avancés'),
                    subtitle: const Text('Accéder aux paramètres de performance avancés'),
                    trailing: const Icon(Icons.settings),
                    onTap: () => context.goNamed('advancedPerformance'),
                  ),
                  ListTile(
                    title: const Text('Nettoyer le cache des médias'),
                    subtitle:
                        const Text('Libérer l\'espace de stockage temporaire'),
                    trailing: const Icon(Icons.cleaning_services),
                    onTap: () => _cleanupTempMedia(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Conseils
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conseils pour de meilleures performances',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceTip(
                    Icons.photo_size_select_large,
                    'Optimisez la taille des images',
                    'Utilisez des images compressées pour accélérer le chargement',
                  ),
                  const Divider(),
                  _buildPerformanceTip(
                    Icons.folder,
                    'Divisez les grandes collections',
                    'Créez plusieurs paquets plutôt qu\'un seul très volumineux',
                  ),
                  const Divider(),
                  _buildPerformanceTip(
                    Icons.video_library,
                    'Attention aux vidéos',
                    'Les vidéos consomment beaucoup de ressources. Utilisez-les avec parcimonie',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTip(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizationItem extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;

  const _OptimizationItem({
    required this.title,
    required this.description,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red.shade300,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: enabled ? null : Colors.grey,
                    fontStyle: enabled ? null : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
