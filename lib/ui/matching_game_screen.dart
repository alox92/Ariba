import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashcards_app/viewmodels/matching_game_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:flashcards_app/ui/components/loading_overlay.dart';
import 'package:flashcards_app/ui/widgets/confetti_animation.dart';
import 'package:go_router/go_router.dart';

class MatchingGameScreen extends StatelessWidget {
  final int deckId;
  final String deckName;

  const MatchingGameScreen({super.key, required this.deckId, required this.deckName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MatchingGameViewModel(
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
        reviewCardUseCase: context.read<ReviewCardUseCase>(),
        deckId: deckId,
      ),
      child: _MatchingGameContent(deckName: deckName),
    );
  }
}

class _MatchingGameContent extends StatefulWidget {
  final String deckName;

  const _MatchingGameContent({required this.deckName});

  @override
  State<_MatchingGameContent> createState() => _MatchingGameContentState();
}

class _MatchingGameContentState extends State<_MatchingGameContent>
    with TickerProviderStateMixin {
  late MatchingGameViewModel _viewModel;
  late AnimationController _confettiController;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<MatchingGameViewModel>(context, listen: false);
    _viewModel.addListener(_handleViewModelChange);
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _confettiController.dispose();
    super.dispose();
  }  void _handleViewModelChange() {
    if (!mounted) {
      return;
    }
    
    if (_viewModel.isGameCompleted) {
      setState(() => _showConfetti = true);
      _confettiController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchingGameViewModel>(
      builder: (context, viewModel, child) {        return MainLayout(
          child: Stack(
            children: [              if (viewModel.isLoading)
                const LoadingOverlay(
                  isLoading: true,
                  child: SizedBox.shrink(),
                )
              else if (viewModel.isGameCompleted)
                _buildGameResults(viewModel)
              else if (viewModel.hasError)
                _buildErrorState(viewModel)
              else if (!viewModel.isGameStarted)
                _buildGameInstructions(viewModel)
              else
                _buildGameContent(viewModel),
                if (_showConfetti)
                ConfettiAnimation(play: _showConfetti),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameInstructions(MatchingGameViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Matching Game',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Match the terms with their definitions!',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to play:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    '1. Select a term on the left',
                    Icons.touch_app,
                  ),
                  _buildInstructionItem(
                    '2. Select the matching definition on the right',
                    Icons.link,
                  ),
                  _buildInstructionItem(
                    '3. Get points for correct matches',
                    Icons.star,
                  ),
                  _buildInstructionItem(
                    '4. Complete all matches to win!',
                    Icons.emoji_events,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),          PrimaryButton(
            onPressed: viewModel.startGame,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text('Start Game'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(MatchingGameViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Game header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score: ${viewModel.score}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: viewModel.progress,
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        'Matches',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '${viewModel.matchedPairs}/${viewModel.totalPairs}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Game board
          Expanded(
            child: Row(
              children: [
                // Terms column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.terms.length,
                          itemBuilder: (context, index) {
                            final term = viewModel.terms[index];
                            final isSelected = viewModel.selectedTerm == term;
                            final isMatched = viewModel.matchedTerms.contains(term);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),                              child: _buildGameCard(
                                context,
                                term.frontText,
                                isSelected: isSelected,
                                isMatched: isMatched,
                                onTap: isMatched ? null : () => viewModel.selectTerm(term),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Definitions column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Definitions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.definitions.length,
                          itemBuilder: (context, index) {
                            final definition = viewModel.definitions[index];
                            final isSelected = viewModel.selectedDefinition == definition;
                            final isMatched = viewModel.matchedDefinitions.contains(definition);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),                              child: _buildGameCard(
                                context,
                                definition.backText,
                                isSelected: isSelected,
                                isMatched: isMatched,
                                onTap: isMatched ? null : () => viewModel.selectDefinition(definition),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          if (viewModel.selectedTerm != null || viewModel.selectedDefinition != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.clearSelection,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Selection'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(                  child: PrimaryButton(                    onPressed: (viewModel.selectedTerm != null && viewModel.selectedDefinition != null)
                        ? viewModel.checkMatch
                        : () {}, // Empty function instead of null
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text('Check Match'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String text, {
    required bool isSelected,
    required bool isMatched,
    VoidCallback? onTap,
  }) {
    Color? backgroundColor;
    Color? textColor;
    Color? borderColor;
      if (isMatched) {
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    }

    return Card(
      elevation: isSelected ? 4 : 2,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected || isMatched ? FontWeight.bold : null,
                  ),
                ),
              ),
              if (isMatched)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameResults(MatchingGameViewModel viewModel) {
    final scorePercentage = (viewModel.score / (viewModel.totalPairs * 100) * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            scorePercentage >= 80 ? Icons.emoji_events : 
            scorePercentage >= 60 ? Icons.thumb_up : Icons.sentiment_satisfied,
            size: 80,            color: scorePercentage >= 80 ? Colors.amber : 
                   scorePercentage >= 60 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Game Completed!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Final Score: ${viewModel.score}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matches: ${viewModel.matchedPairs}/${viewModel.totalPairs}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [              Expanded(
                child: PrimaryButton(
                  onPressed: viewModel.restartGame,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Play Again'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Deck'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MatchingGameViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load matching game',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),            PrimaryButton(
              onPressed: viewModel.loadCards,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
