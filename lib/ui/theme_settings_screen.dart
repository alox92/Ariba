import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flashcards_app/services/theme_service.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  // Liste des polices disponibles
  final List<String> availableFonts = [
    'Roboto',
    'Montserrat',
    'Lato',
    'Open Sans',
    'Poppins',
    'Nunito',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Provider.of<ThemeService>(context);
    final ThemePreferences prefs = themeService.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation du thème'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Réinitialiser',
            onPressed: () => _showResetConfirmation(context, themeService),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Mode thème
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode d\'affichage',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeModeSelector(context, themeService),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Couleurs
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Couleurs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Couleur primaire'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: prefs.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    onTap: () => _showColorPicker(
                      context,
                      prefs.primaryColor,
                      (color) => themeService.setPrimaryColor(color),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                        'Couleur secondaire'), // Changed from 'Couleur d\'accent'
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: prefs
                            .secondaryColor, // Changed from prefs.accentColor
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    onTap: () => _showColorPicker(
                      context,
                      prefs.secondaryColor, // Changed from prefs.accentColor
                      (color) => themeService.setSecondaryColor(
                          color), // Changed from setAccentColor
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Police
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Police',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: prefs.fontFamily,
                    decoration: const InputDecoration(
                      labelText: 'Famille de police',
                    ),
                    items: availableFonts.map((font) {
                      return DropdownMenuItem<String>(
                        value: font,
                        child: Text(font, style: TextStyle(fontFamily: font)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        themeService.setFontFamily(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Style des composants
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Style des composants',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Arrondi des bords: ${prefs.borderRadius.toStringAsFixed(1)}'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: prefs.borderRadius,
                          max: 24.0,
                          divisions: 24,
                          label: prefs.borderRadius.toStringAsFixed(1),
                          onChanged: (value) {
                            themeService.setBorderRadius(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Élévation des cartes: ${prefs.cardElevation.toStringAsFixed(1)}'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: prefs.cardElevation,
                          max: 10.0,
                          divisions: 10,
                          label: prefs.cardElevation.toStringAsFixed(1),
                          onChanged: (value) {
                            themeService.setCardElevation(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Aperçu
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aperçu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Titre de carte',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sous-titre avec la police ${prefs.fontFamily}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Action'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Annuler'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(
      BuildContext context, ThemeService themeService) {
    return Wrap(
      spacing: 8.0,
      children: [
        ChoiceChip(
          label: const Text('Clair'),
          selected: themeService.preferences.themeMode == ThemeOption.light,
          onSelected: (selected) {
            if (selected) {
              themeService.setThemeMode(ThemeOption.light);
            }
          },
        ),
        ChoiceChip(
          label: const Text('Sombre'),
          selected: themeService.preferences.themeMode == ThemeOption.dark,
          onSelected: (selected) {
            if (selected) {
              themeService.setThemeMode(ThemeOption.dark);
            }
          },
        ),
        ChoiceChip(
          label: const Text('Système'),
          selected: themeService.preferences.themeMode == ThemeOption.system,
          onSelected: (selected) {
            if (selected) {
              themeService.setThemeMode(ThemeOption.system);
            }
          },
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor,
      Function(Color) onColorChanged) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              hexInputBar: true,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Réinitialiser le thème'),
          content: const Text(
              'Voulez-vous vraiment réinitialiser toutes les préférences de thème aux valeurs par défaut?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                themeService.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Préférences réinitialisées')),
                );
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }
}
