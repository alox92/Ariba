import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';

import 'package:flashcards_app/viewmodels/review_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/services/media_service.dart';
import 'package:flashcards_app/ui/widgets/confetti_animation.dart';
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:flashcards_app/ui/components/loading_overlay.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';
import 'package:super_editor/super_editor.dart' as se;
import 'package:uuid/uuid.dart';

class ReviewScreen extends StatelessWidget {
  final int deckId;
  final String deckName;
  final bool isReverseMode;

  const ReviewScreen({
    super.key, 
    required this.deckId, 
    required this.deckName,
    this.isReverseMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReviewViewModel(
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
        reviewCardUseCase: context.read<ReviewCardUseCase>(),
        deckId: deckId,
        isReverseMode: isReverseMode,
      ),
      child: _ReviewScreenContent(deckName: deckName, isReverseMode: isReverseMode),
    );
  }
}

class _ReviewScreenContent extends StatefulWidget {
  final String deckName;
  final bool isReverseMode;

  const _ReviewScreenContent({
    required this.deckName,
    this.isReverseMode = false,
  });

  @override
  State<_ReviewScreenContent> createState() => _ReviewScreenContentState();
}

class _ReviewScreenContentState extends State<_ReviewScreenContent>
    with TickerProviderStateMixin {
  // Fields
  late ReviewViewModel _viewModel;
  late se.MutableDocument _frontDocument;
  late se.MutableDocument _backDocument;
  late se.Editor _frontEditor;
  late se.Editor _backEditor;
  late se.MutableDocumentComposer _frontComposer;
  late se.MutableDocumentComposer _backComposer;
  late MediaService _mediaService;
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _showConfetti = false;

  se.MutableDocument _initializeReadOnlyDocument(String? content) {
    final String textContent = content ?? "";
    // Assuming plain text. If content can be structured (e.g., Markdown, HTML),
    // a more sophisticated deserialization would be needed here.
    return se.MutableDocument(nodes: [
      se.ParagraphNode(
        id: const Uuid().v4(),
        text: se.AttributedText(textContent),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _mediaService = MediaService();
    _viewModel = Provider.of<ReviewViewModel>(context, listen: false);
    _viewModel.addListener(_handleViewModelChange);

    _frontDocument = _initializeReadOnlyDocument(null);
    _backDocument = _initializeReadOnlyDocument(null);
    _frontComposer = se.MutableDocumentComposer();
    _backComposer = se.MutableDocumentComposer();

    _frontEditor = se.createDefaultDocumentEditor(
        document: _frontDocument, composer: _frontComposer);
    _backEditor = se.createDefaultDocumentEditor(
        document: _backDocument, composer: _backComposer);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _updateSuperEditorDocuments(); // Changed from _updateQuillControllers
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _frontDocument.dispose();
    _backDocument.dispose();
    _frontComposer.dispose();
    _backComposer.dispose();
    // Editors themselves don't have a dispose method; their documents and composers do.
    _mediaService.stopAudio();
    _slideController.dispose();
    super.dispose();
  }

  void _handleViewModelChange() {
    if (!mounted) {
      return;
    }
    final viewModel = _viewModel;
    if (viewModel.currentCardChanged) {
      _updateSuperEditorDocuments(); // Changed from _updateQuillControllers
      _slideController.forward(from: 0.0);
      if (_cardKey.currentState?.isFront == false) {
        _cardKey.currentState!.toggleCard();
      }
    }
    if (viewModel.isShowingAnswer && _cardKey.currentState?.isFront == true) {
      _cardKey.currentState!.toggleCard();
    }
    setState(() => _showConfetti = false);
  }

  void _updateSuperEditorDocuments() {
    // Renamed from _updateQuillControllers
    // Use the ViewModel's reverse-mode-aware text getters
    final String frontText = _viewModel.currentFrontText ?? "";
    final String backText = _viewModel.currentBackText ?? "";

    // Create new documents with the new content
    final newFrontDocument = _initializeReadOnlyDocument(frontText);
    final newBackDocument = _initializeReadOnlyDocument(backText);

    // Dispose the old documents that were being used by the editors
    _frontEditor.document.dispose();
    _backEditor.document.dispose();

    // Update the documents in the state
    _frontDocument = newFrontDocument;
    _backDocument = newBackDocument;

    // Update the editors to use the new documents with existing composers
    _frontEditor = se.createDefaultDocumentEditor(
        document: _frontDocument, composer: _frontComposer);
    _backEditor = se.createDefaultDocumentEditor(
        document: _backDocument, composer: _backComposer);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: Text(
            widget.isReverseMode 
                ? 'Révision Inversée: ${widget.deckName}' 
                : 'Révision: ${widget.deckName}',
            style: DesignSystem.titleLarge
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          if (!viewModel.isLoading && !viewModel.isSessionComplete)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text('${viewModel.remainingCards} restantes',
                    style: DesignSystem.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isLoading,
        child: Stack(
          children: [
            _buildBody(context, viewModel),
            if (_showConfetti) const ConfettiAnimation(play: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReviewViewModel viewModel) {
    if (viewModel.isSessionComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Session terminée !',
                style: DesignSystem.h3
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.restartSession(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary),
              child: const Text('Recommencer'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        SlideTransition(
          position: _slideAnimation,
          child: FlipCard(
            key: _cardKey,
            flipOnTouch: false,
            front: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: se.SuperReader(
                    document: _frontDocument,
                    stylesheet: se.Stylesheet(
                      rules: [
                        se.StyleRule(
                            se.BlockSelector.all,
                            (doc, node) =>
                                {se.Styles.textStyle: DesignSystem.bodyLarge})
                      ],
                      inlineTextStyler: (attributions, existingStyles) =>
                          existingStyles,
                    ),
                    componentBuilders: se.defaultComponentBuilders,
                  )),
            ),
            back: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: se.SuperReader(
                    document: _backDocument,
                    stylesheet: se.Stylesheet(
                      rules: [
                        se.StyleRule(
                            se.BlockSelector.all,
                            (doc, node) =>
                                {se.Styles.textStyle: DesignSystem.bodyLarge})
                      ],
                      inlineTextStyler: (attributions, existingStyles) =>
                          existingStyles,
                    ),
                    componentBuilders: se.defaultComponentBuilders,
                  )),
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PrimaryButton(
                          onPressed: () => viewModel.submitReview(0),
                          child: const Text('Again')))),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PrimaryButton(
                          onPressed: () => viewModel.showAnswer(),
                          child: const Text('Show')))),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PrimaryButton(
                          onPressed: () => viewModel.submitReview(2),
                          child: const Text('Good')))),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PrimaryButton(
                          onPressed: () => viewModel.submitReview(3),
                          child: const Text('Easy')))),
            ],
          ),
        ),
      ],
    );
  }
}
