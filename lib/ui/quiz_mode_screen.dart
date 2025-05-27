import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashcards_app/viewmodels/quiz_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:flashcards_app/ui/components/loading_overlay.dart';
import 'package:flashcards_app/ui/widgets/confetti_animation.dart';
import 'package:go_router/go_router.dart';

class QuizModeScreen extends StatelessWidget {
  final int deckId;
  final String deckName;

  const QuizModeScreen({super.key, required this.deckId, required this.deckName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizViewModel(
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
        reviewCardUseCase: context.read<ReviewCardUseCase>(),
        deckId: deckId,
      ),
      child: _QuizModeContent(deckName: deckName),
    );
  }
}

class _QuizModeContent extends StatefulWidget {
  final String deckName;

  const _QuizModeContent({required this.deckName});

  @override
  State<_QuizModeContent> createState() => _QuizModeContentState();
}

class _QuizModeContentState extends State<_QuizModeContent>
    with TickerProviderStateMixin {
  late QuizViewModel _viewModel;
  late AnimationController _progressController;
  late AnimationController _confettiController;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<QuizViewModel>(context, listen: false);
    _viewModel.addListener(_handleViewModelChange);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }  void _handleViewModelChange() {
    if (!mounted) {
      return;
    }
    
    if (_viewModel.isQuizCompleted) {
      setState(() {
        _showConfetti = true;
      });
      _confettiController.forward();
    }
    
    _progressController.animateTo(_viewModel.progress);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {        return MainLayout(
          child: Stack(
            children: [              if (viewModel.isLoading)
                LoadingOverlay(isLoading: true, child: Container())
              else if (viewModel.isQuizCompleted)
                _buildQuizResults(viewModel)
              else if (viewModel.hasError)
                _buildErrorState(viewModel)
              else
                _buildQuizContent(viewModel),
                if (_showConfetti)
                ConfettiAnimation(play: _showConfetti),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizContent(QuizViewModel viewModel) {
    final question = viewModel.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          _buildProgressBar(viewModel),
          const SizedBox(height: 24),
          
          // Question counter
          Text(
            'Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.totalQuestions}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Question
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = viewModel.selectedAnswerIndex == index;
                final isCorrect = index == question.correctAnswerIndex;
                final showResult = viewModel.hasAnswered;
                
                Color? backgroundColor;
                Color? textColor;
                IconData? icon;
                
                if (showResult) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.withValues(alpha: 0.1);
                    textColor = Colors.green;
                    icon = Icons.check_circle;
                  } else if (isSelected) {
                    backgroundColor = Colors.red.withValues(alpha: 0.1);
                    textColor = Colors.red;
                    icon = Icons.cancel;
                  }
                } else if (isSelected) {
                  backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
                  textColor = Theme.of(context).colorScheme.primary;
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: isSelected ? 4 : 2,
                    color: backgroundColor,
                    child: InkWell(
                      onTap: viewModel.hasAnswered 
                          ? null 
                          : () => viewModel.selectAnswer(index),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected || (showResult && isCorrect)
                                    ? (textColor ?? Theme.of(context).colorScheme.primary)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: textColor ?? Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: showResult && (isCorrect || isSelected)
                                    ? Icon(icon, color: Colors.white, size: 20)
                                    : Text(
                                        String.fromCharCode(65 + index), // A, B, C, D
                                        style: TextStyle(
                                          color: isSelected 
                                              ? Colors.white 
                                              : (textColor ?? Theme.of(context).colorScheme.onSurface),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: isSelected ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),          // Action buttons
          if (viewModel.hasAnswered)
            PrimaryButton(
              onPressed: viewModel.nextQuestion,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(viewModel.isLastQuestion ? Icons.flag : Icons.arrow_forward),
                  const SizedBox(width: 8),
                  Text(viewModel.isLastQuestion ? 'Finish Quiz' : 'Next Question'),
                ],
              ),
            )
          else            PrimaryButton(
              onPressed: viewModel.selectedAnswerIndex != null 
                  ? viewModel.submitAnswer 
                  : () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  const Text('Submit Answer'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuizViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${(viewModel.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuizResults(QuizViewModel viewModel) {
    final scorePercentage = (viewModel.score / viewModel.totalQuestions * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            scorePercentage >= 80 ? Icons.emoji_events : 
            scorePercentage >= 60 ? Icons.thumb_up : Icons.sentiment_satisfied,
            size: 80,
            color: scorePercentage >= 80 ? Colors.amber : 
                   scorePercentage >= 60 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Completed!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Score: ${viewModel.score}/${viewModel.totalQuestions}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$scorePercentage%',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(                child: PrimaryButton(
                  onPressed: viewModel.retryQuiz,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(width: 8),
                      const Text('Retry Quiz'),
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

  Widget _buildErrorState(QuizViewModel viewModel) {
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
              'Failed to load quiz',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),            PrimaryButton(
              onPressed: viewModel.loadQuiz,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  const Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
