import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashcards_app/viewmodels/speed_round_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:flashcards_app/ui/components/loading_overlay.dart';
import 'package:flashcards_app/ui/widgets/confetti_animation.dart';
import 'package:go_router/go_router.dart';

class SpeedRoundScreen extends StatelessWidget {
  final int deckId;
  final String deckName;

  const SpeedRoundScreen({super.key, required this.deckId, required this.deckName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpeedRoundViewModel(
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
        reviewCardUseCase: context.read<ReviewCardUseCase>(),
        deckId: deckId,
      ),
      child: _SpeedRoundContent(deckName: deckName),
    );
  }
}

class _SpeedRoundContent extends StatefulWidget {
  final String deckName;

  const _SpeedRoundContent({required this.deckName});

  @override
  State<_SpeedRoundContent> createState() => _SpeedRoundContentState();
}

class _SpeedRoundContentState extends State<_SpeedRoundContent>
    with TickerProviderStateMixin {
  late SpeedRoundViewModel _viewModel;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late Animation<double> _pulseAnimation;
  bool _showConfetti = false;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SpeedRoundViewModel>(context, listen: false);
    _viewModel.addListener(_handleViewModelChange);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleViewModelChange() {
    if (!mounted) {
      return;
    }
    
    if (_viewModel.isGameComplete) {
      setState(() {
        _showConfetti = true;
      });
      _confettiController.forward();
      _pulseController.stop();
    } else if (_viewModel.isGameActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedRoundViewModel>(
      builder: (context, viewModel, child) {
        return MainLayout(
          child: Stack(
            children: [              if (viewModel.isLoading)
                LoadingOverlay(
                  isLoading: true,
                  child: Container(),
                )
              else if (viewModel.isGameComplete)
                _buildGameResults(viewModel)
              else if (viewModel.error != null)
                _buildErrorState(viewModel)
              else if (!viewModel.isGameActive && !viewModel.isGameComplete)
                _buildStartScreen(viewModel)
              else
                _buildGameContent(viewModel),
              
              if (_showConfetti)
                ConfettiAnimation(play: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartScreen(SpeedRoundViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flash_on,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Speed Round',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test your knowledge in a fast-paced challenge!',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Game Rules:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRuleItem(
                    icon: Icons.timer,
                    text: '60 seconds on the clock',
                  ),
                  _buildRuleItem(
                    icon: Icons.psychology,
                    text: 'Answer as many cards as possible',
                  ),
                  _buildRuleItem(
                    icon: Icons.speed,
                    text: 'Quick reactions earn bonus points',
                  ),
                  _buildRuleItem(
                    icon: Icons.star,
                    text: 'Streak bonuses for consecutive correct answers',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: PrimaryButton(
                  onPressed: viewModel.startGame,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Start Speed Round'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
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
  Widget _buildGameContent(SpeedRoundViewModel viewModel) {    final card = viewModel.currentCard;
    if (card == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Timer and score row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimerWidget(viewModel),
              _buildScoreWidget(viewModel),
            ],
          ),
          const SizedBox(height: 24),
          
          // Streak indicator
          if (viewModel.streak > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.whatshot, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${viewModel.streak}x Streak!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Question card
          Expanded(
            child: Center(
              child: Card(
                elevation: 8,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showAnswer ? 'Answer:' : 'Question:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showAnswer ? card.backText : card.frontText,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (!_showAnswer) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Do you know the answer?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          if (_showAnswer)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAnswer(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Incorrect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markAnswer(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Correct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            )
          else
            PrimaryButton(
              onPressed: () {
                setState(() {
                  _showAnswer = true;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Show Answer'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _markAnswer(bool isCorrect) {
    _viewModel.answerCard(isCorrect);
    setState(() {
      _showAnswer = false;
    });
  }

  Widget _buildTimerWidget(SpeedRoundViewModel viewModel) {
    final timeLeft = viewModel.timeRemaining;
    final isUrgent = timeLeft <= 10;
    
    return Card(
      color: isUrgent ? Colors.red.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${timeLeft}s',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreWidget(SpeedRoundViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(
              '${viewModel.score}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameResults(SpeedRoundViewModel viewModel) {
    final accuracy = viewModel.totalAnswers > 0 
        ? (viewModel.correctAnswers / viewModel.totalAnswers * 100).round()
        : 0;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Time\'s Up!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          
          // Results summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildResultStat(
                    icon: Icons.star,
                    label: 'Final Score',
                    value: viewModel.score.toString(),
                    color: Colors.amber,
                  ),
                  const Divider(),
                  _buildResultStat(
                    icon: Icons.check_circle,
                    label: 'Correct Answers',
                    value: '${viewModel.correctAnswers}/${viewModel.totalAnswers}',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _buildResultStat(
                    icon: Icons.percent,
                    label: 'Accuracy',
                    value: '$accuracy%',
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _buildResultStat(
                    icon: Icons.whatshot,
                    label: 'Best Streak',
                    value: viewModel.bestStreak.toString(),
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  onPressed: viewModel.restartGame,
                  child: Row(
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

  Widget _buildResultStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SpeedRoundViewModel viewModel) {
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
              'Failed to load speed round',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () {
                // Reload the provider to restart the ViewModel
                context.read<SpeedRoundViewModel>().restartGame();
              },
              child: Row(
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
