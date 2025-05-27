import 'package:file_picker/file_picker.dart'; // For file picking
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:super_editor/super_editor.dart' as se;
import 'package:uuid/uuid.dart';

import 'package:flashcards_app/domain/entities/deck.dart' as domain;
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/viewmodels/card_viewmodel.dart';
import 'package:flashcards_app/ui/theme/design_system.dart'; // Corrected import path
import 'package:flashcards_app/ui/components/primary_button.dart'; // Corrected import path

class LocalFlashCard {
  final int? id;
  final int deckId;
  String frontText;
  String backText;
  String tags;
  DateTime createdAt;
  DateTime? lastReviewed;
  int interval;
  double easeFactor;
  String? frontImage;
  String? backImage;
  String? frontAudio;
  String? backAudio;

  LocalFlashCard({
    this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.tags,
    required this.createdAt,
    this.lastReviewed,
    required this.interval,
    required this.easeFactor,
    this.frontImage,
    this.backImage,
    this.frontAudio,
    this.backAudio,
  });

  factory LocalFlashCard.fromDomainCard(domain.Card entity) {
    return LocalFlashCard(
      id: entity.id,
      deckId: entity.deckId,
      frontText: entity.frontText,
      backText: entity.backText,
      tags: entity.tags ?? '',
      createdAt: entity.createdAt,
      lastReviewed: entity.lastReviewed,
      interval: entity.intervalDays,
      easeFactor: entity.easinessFactor,
      frontImage: entity.frontImagePath,
      backImage: entity.backImagePath,
      frontAudio: entity.frontAudioPath,
      backAudio: entity.backAudioPath,
    );
  }
}

class EditCardScreen extends StatefulWidget {
  final domain.Deck deck; // Uses domain Deck entity
  final domain.Card? card; // Uses domain Card entity

  const EditCardScreen({
    super.key,
    required this.deck,
    this.card,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late CardViewModel _cardViewModel;

  late final se.MutableDocument _frontDocument;
  late final se.MutableDocument _backDocument;
  late final se.MutableDocumentComposer _frontComposer;
  late final se.MutableDocumentComposer _backComposer;
  late se.Editor _frontEditor;
  late se.Editor _backEditor;

  String? _frontImagePath;
  String? _backImagePath;
  String? _frontAudioPath;
  String? _backAudioPath;
  String _tags = ''; // Added to store tags

  LocalFlashCard? _internalFlashCard;

  void _updatePlainText() {
    if (_internalFlashCard != null) {
      _internalFlashCard!.frontText = _getDocumentAsPlainText(_frontDocument);
      _internalFlashCard!.backText = _getDocumentAsPlainText(_backDocument);
      // setState(() {}); // Uncomment if UI needs to react to plain text changes immediately
      // print("Updated plain text: Front: ${_internalFlashCard!.frontText}, Back: ${_internalFlashCard!.backText}");
    }
  }

  void _handleComposerChange() {
    // print("Composer changed, updating plain text.");
    _updatePlainText();
  }

  @override
  void initState() {
    super.initState();
    _cardViewModel = Provider.of<CardViewModel>(context, listen: false);

    String initialFrontText = '';
    String initialBackText = '';

    if (widget.card != null) {
      _internalFlashCard =
          LocalFlashCard.fromDomainCard(widget.card!);
      initialFrontText = _internalFlashCard!.frontText;
      initialBackText = _internalFlashCard!.backText;
      _frontImagePath = _internalFlashCard!.frontImage;
      _backImagePath = _internalFlashCard!.backImage;
      _frontAudioPath = _internalFlashCard!.frontAudio;
      _backAudioPath = _internalFlashCard!.backAudio;
      _tags = _internalFlashCard!.tags; // Initialize tags
    } else {
      final now = DateTime.now();
      _internalFlashCard = LocalFlashCard(
        deckId: widget.deck.id,
        frontText: '',
        backText: '',
        tags: '',
        createdAt: now,
        interval: 0,
        easeFactor: 2.5,
      );
    }

    _frontDocument = se.MutableDocument(
      nodes: [
        se.ParagraphNode(
          id: const Uuid().v4(),
          text: se.AttributedText(initialFrontText),
        ),
      ],
    );
    _backDocument = se.MutableDocument(
      nodes: [
        se.ParagraphNode(
          id: const Uuid().v4(),
          text: se.AttributedText(initialBackText),
        ),
      ],
    );

    _frontComposer = se.MutableDocumentComposer();
    _backComposer = se.MutableDocumentComposer();

    _frontEditor = se.createDefaultDocumentEditor(
      document: _frontDocument,
      composer: _frontComposer,
    );
    _backEditor = se.createDefaultDocumentEditor(
      document: _backDocument,
      composer: _backComposer,
    );

    // Remove listeners from _frontDocument and _backDocument
    // _frontDocument.addListener(_handleFrontDocumentChange);
    // _backDocument.addListener(_handleBackDocumentChange);

    // Add listeners to composers
    _frontComposer.addListener(_handleComposerChange);
    _backComposer.addListener(_handleComposerChange);

    _updatePlainText(); // Initial update
  }

  @override
  void dispose() {
    // Remove listeners from _frontDocument and _backDocument
    // _frontDocument.removeListener(_handleFrontDocumentChange);
    // _backDocument.removeListener(_handleBackDocumentChange);

    // Remove listeners from composers
    _frontComposer.removeListener(_handleComposerChange);
    _backComposer.removeListener(_handleComposerChange);

    _frontComposer.dispose();
    _backComposer.dispose();
    _frontDocument.dispose();
    _backDocument.dispose();

    super.dispose();
  }

  String _getDocumentAsPlainText(se.Document document) {
    final buffer = StringBuffer();
    for (int i = 0; i < document.nodeCount; i++) {
      final node = document.getNodeAt(i);
      if (node is se.ParagraphNode) {
        buffer.writeln(node.text.toPlainText());
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      final frontText = _getDocumentAsPlainText(_frontEditor.document);
      final backText = _getDocumentAsPlainText(_backEditor.document);

      if (frontText.isEmpty &&
          backText.isEmpty &&
          _frontImagePath == null &&
          _backImagePath == null &&
          _frontAudioPath == null &&
          _backAudioPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La carte est vide. Veuillez ajouter du contenu.')),
        );
        return;
      }

      try {
        if (_internalFlashCard != null && widget.card != null) {
          // Update existing card
          await _cardViewModel.updateCard(
            widget.card!.id,
            frontText,
            backText,
            widget.deck.id, // Add missing deckId parameter
            frontImagePath: _frontImagePath,
            backImagePath: _backImagePath,
            frontAudioPath: _frontAudioPath,
            backAudioPath: _backAudioPath,
            tags: _tags,
          );
        } else {
          // Add new card
          await _cardViewModel.addCard(
            widget.deck.id,
            frontText,
            backText,
            frontImagePath: _frontImagePath,
            backImagePath: _backImagePath,
            frontAudioPath: _frontAudioPath,
            backAudioPath: _backAudioPath,
            tags: _tags,
          );
        }
        if (mounted) {
          GoRouter.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erreur lors de l\'enregistrement de la carte: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires.')),
      );
    }
  }

  Widget _buildEditor(se.Editor editor, String hintText) {
    return SizedBox(
      height: 200, // Added fixed height
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: se.SuperEditor(
          editor: editor,
          stylesheet: se.Stylesheet(
            rules: [
              se.StyleRule(
                se.BlockSelector('paragraph'),
                (doc, docNode) => {
                  se.Styles.textStyle: DesignSystem.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                  se.Styles.padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Added padding via stylesheet
                },
              ),
            ],
            inlineTextStyler: (attributions, existingStyles) => existingStyles,
          ),
          componentBuilders: se.defaultComponentBuilders,
        ),
      ),
    );
  }

  Future<void> _pickFile(Function(String) onFilePicked,
      {List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowedExtensions: allowedExtensions);
      if (result != null && result.files.single.path != null) {
        setState(() {
          onFilePicked(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection du fichier: $e')),
        );
      }
    }
  }

  Widget _buildMediaPicker(String label, String? currentPath,
      Function(String) onFilePicked, Function() onClear, FileType fileType) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: DesignSystem.bodyMedium
                .copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentPath ?? 'Aucun fichier sélectionné',
                  style: DesignSystem.caption.copyWith(
                      color: currentPath != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant.withAlpha(
                              178)), // Replaced withOpacity with withAlpha
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
              onPressed: () => _pickFile(onFilePicked,
                  allowedExtensions: fileType == FileType.image
                      ? ['jpg', 'png', 'gif']
                      : ['mp3', 'wav']),
            ),
            if (currentPath != null)
              IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.error),
                onPressed: onClear,
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.colorScheme.surface,
      statusBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.card == null ? 'Nouvelle Carte' : 'Modifier Carte',
            style: DesignSystem.titleMedium
                .copyWith(color: theme.colorScheme.onSurface)),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Recto',
                  style: DesignSystem.titleLarge
                      .copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              _buildEditor(_frontEditor, 'Contenu du recto...'),
              const SizedBox(height: 16),
              _buildMediaPicker(
                'Image Recto',
                _frontImagePath,
                (path) => setState(() => _frontImagePath = path),
                () => setState(() => _frontImagePath = null),
                FileType.image,
              ),
              const SizedBox(height: 16),
              _buildMediaPicker(
                'Audio Recto',
                _frontAudioPath,
                (path) => setState(() => _frontAudioPath = path),
                () => setState(() => _frontAudioPath = null),
                FileType.audio,
              ),
              const SizedBox(height: 24),
              Text('Verso',
                  style: DesignSystem.titleLarge
                      .copyWith(color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              _buildEditor(_backEditor, 'Contenu du verso...'),
              const SizedBox(height: 16),
              _buildMediaPicker(
                'Image Verso',
                _backImagePath,
                (path) => setState(() => _backImagePath = path),
                () => setState(() => _backImagePath = null),
                FileType.image,
              ),
              const SizedBox(height: 16),
              _buildMediaPicker(
                'Audio Verso',
                _backAudioPath,
                (path) => setState(() => _backAudioPath = path),
                () => setState(() => _backAudioPath = null),
                FileType.audio,
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _tags,
                decoration: const InputDecoration(
                  labelText: 'Tags (séparés par des virgules)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _tags = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: _saveCard,
                child: Text(widget.card == null
                    ? 'Ajouter Carte'
                    : 'Sauvegarder Modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
