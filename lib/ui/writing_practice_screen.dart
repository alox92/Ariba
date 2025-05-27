import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/viewmodels/writing_practice_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';

class WritingPracticeScreen extends StatefulWidget {
  final int deckId;
  final String deckName;

  const WritingPracticeScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen>
    with TickerProviderStateMixin {
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;
  
  late AnimationController _progressAnimationController;
  late AnimationController _cardFlipController;
  late AnimationController _scoreAnimationController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _scoreAnimation;

  Timer? _confettiTimer;
  final List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _answerFocusNode = FocusNode();
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );
    
    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
    );
    
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );

    // Auto-focus on answer input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _progressAnimationController.dispose();
    _cardFlipController.dispose();
    _scoreAnimationController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _onAnswerSubmitted(WritingPracticeViewModel viewModel) {
    if (_answerController.text.trim().isNotEmpty) {
      viewModel.updateUserAnswer(_answerController.text);
      viewModel.submitAnswer();
      
      if (viewModel.isCorrect) {
        _playCorrectAnswerAnimation();
      } else {
        _playIncorrectAnswerAnimation();
      }
    }
  }

  void _playCorrectAnswerAnimation() {
    _scoreAnimationController.forward();
    _startConfetti();
    HapticFeedback.lightImpact();
  }

  void _playIncorrectAnswerAnimation() {
    _cardFlipController.forward().then((_) {
      Timer(const Duration(milliseconds: 500), () {
        _cardFlipController.reverse();
      });
    });
    HapticFeedback.heavyImpact();
  }

  void _startConfetti() {
    final random = math.Random();
    _confettiParticles.clear();
    
    for (int i = 0; i < 30; i++) {
      _confettiParticles.add(ConfettiParticle(
        x: random.nextDouble() * MediaQuery.of(context).size.width,
        y: -20,
        color: Color.lerp(Colors.yellow, Colors.orange, random.nextDouble())!,
        size: random.nextDouble() * 8 + 4,
        velocity: random.nextDouble() * 100 + 50,
      ));
    }
    
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        for (var particle in _confettiParticles) {
          particle.update();
        }
        _confettiParticles.removeWhere((p) => p.y > MediaQuery.of(context).size.height);
      });
      
      if (_confettiParticles.isEmpty) {
        timer.cancel();
      }
    });
  }

  void _nextCard(WritingPracticeViewModel viewModel) {
    _answerController.clear();
    _scoreAnimationController.reset();
    _cardFlipController.reset();
    viewModel.nextCard();
    _progressAnimationController.forward();
    
    // Refocus on input for next question
    Timer(const Duration(milliseconds: 100), () {
      _answerFocusNode.requestFocus();
    });
  }

  void _getHint(WritingPracticeViewModel viewModel) {
    viewModel.getHint();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WritingPracticeViewModel>(
      create: (context) => WritingPracticeViewModel(
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
        reviewCardUseCase: context.read<ReviewCardUseCase>(),
        deckId: widget.deckId,
      ),      child: MainLayout(
        child: Consumer<WritingPracticeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError) {
              return _buildErrorWidget(viewModel.errorMessage ?? 'Unknown error');
            }

            if (viewModel.isSessionComplete) {
              return _buildSessionCompleteWidget(viewModel);
            }

            return _buildWritingPracticeContent(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Error Loading Cards',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCompleteWidget(WritingPracticeViewModel viewModel) {
    final accuracyPercentage = (viewModel.accuracy * 100).round();
    final timeSpent = Duration(seconds: viewModel.timeSpentSeconds);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            _buildStatCard('Total Score', '${viewModel.score}', Icons.star),
            const SizedBox(height: 16),
            _buildStatCard('Accuracy', '$accuracyPercentage%', Icons.track_changes),
            const SizedBox(height: 16),
            _buildStatCard(
              'Time Spent',
              '${timeSpent.inMinutes}:${(timeSpent.inSeconds % 60).toString().padLeft(2, '0')}',
              Icons.timer,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Correct Answers',
              '${viewModel.correctAnswers}/${viewModel.totalAnswers}',
              Icons.check_circle,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart session
                    context.read<WritingPracticeViewModel>().loadCards();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Practice Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingPracticeContent(WritingPracticeViewModel viewModel) {
    final currentCard = viewModel.currentCard;
    
    if (currentCard == null) {
      return const Center(child: Text('No cards available'));
    }

    return Stack(
      children: [
        // Confetti overlay
        if (_confettiParticles.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(_confettiParticles),
            ),
          ),
        
        // Main content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProgressHeader(viewModel),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildCardContent(viewModel, currentCard),
                ),
                const SizedBox(height: 24),
                _buildAnswerSection(viewModel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(WritingPracticeViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card ${viewModel.currentCardIndex + 1} of ${viewModel.cards.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_scoreAnimation.value * 0.2),
                      child: Text(
                        '${viewModel.score}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: viewModel.progress * _progressAnimation.value,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatChip(
              Icons.check_circle,
              '${viewModel.correctAnswers}',
              Colors.green,
            ),
            _buildStatChip(
              Icons.cancel,
              '${viewModel.totalAnswers - viewModel.correctAnswers}',
              Colors.red,
            ),
            _buildStatChip(
              Icons.lightbulb,
              '${viewModel.hintsUsed}',
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(value),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildCardContent(WritingPracticeViewModel viewModel, currentCard) {
    return AnimatedBuilder(
      animation: _cardFlipAnimation,
      builder: (context, child) {
        final isShowingBack = _cardFlipAnimation.value > 0.5;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardFlipAnimation.value * math.pi),
          child: Card(
            elevation: 8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isShowingBack) ...[
                    Icon(
                      Icons.quiz,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Write the answer for:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _extractTextFromJson(currentCard.frontText),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: Column(
                        children: [
                          Icon(
                            viewModel.isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 48,
                            color: viewModel.isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            viewModel.isCorrect ? 'Correct!' : 'Incorrect',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: viewModel.isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Correct answer:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _extractTextFromJson(currentCard.backText),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Show hints if available
                  if (viewModel.hints.isNotEmpty && !isShowingBack) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Hints:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...viewModel.hints.map((hint) => Text(
                            hint,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerSection(WritingPracticeViewModel viewModel) {
    if (viewModel.isAnswerSubmitted) {
      return _buildNextCardButton(viewModel);
    }

    return Column(
      children: [
        TextField(
          controller: _answerController,
          focusNode: _answerFocusNode,
          decoration: InputDecoration(
            labelText: 'Your answer',
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.edit),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.hints.length < 3)
                  IconButton(
                    onPressed: () => _getHint(viewModel),
                    icon: const Icon(Icons.lightbulb_outline),
                    tooltip: 'Get hint (-1 point)',
                  ),
                IconButton(
                  onPressed: () => _onAnswerSubmitted(viewModel),
                  icon: const Icon(Icons.send),
                  tooltip: 'Submit answer',
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onAnswerSubmitted(viewModel),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: viewModel.hints.length < 3 ? () => _getHint(viewModel) : null,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text('Hint (${viewModel.hints.length}/3)'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _answerController.text.trim().isNotEmpty 
                    ? () => _onAnswerSubmitted(viewModel)
                    : null,
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextCardButton(WritingPracticeViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _nextCard(viewModel),
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          viewModel.remainingCards > 0 ? 'Next Card' : 'Finish Session',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }  String _extractTextFromJson(String? jsonText) {
    if (jsonText == null || jsonText.isEmpty) {
      return '';
    }
    
    // Simple text extraction - in a real app, you might want to parse JSON properly
    // This handles both plain text and JSON format from super_editor
    try {
      // If it's plain text, return as is
      if (!jsonText.contains('"text"')) {
        return jsonText;
      }
      
      // Simple regex to extract text content from JSON
      final RegExp textRegex = RegExp(r'"text":\s*"([^"]*)"');
      final matches = textRegex.allMatches(jsonText);
      
      if (matches.isNotEmpty) {
        return matches.map((match) => match.group(1) ?? '').join(' ');
      }
      
      return jsonText;
    } catch (e) {
      return jsonText;
    }
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double velocity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
  });

  void update() {
    y += velocity * 0.016; // 60 FPS
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
