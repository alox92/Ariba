import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;

class StudyModesScreen extends StatefulWidget {
  final domain.Deck deck;

  const StudyModesScreen({super.key, required this.deck});

  @override
  State<StudyModesScreen> createState() => _StudyModesScreenState();
}

class _StudyModesScreenState extends State<StudyModesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for the cards
    _slideAnimations = List.generate(6, (index) {
      return Tween<Offset>(
        begin: const Offset(0.0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _fadeAnimations = List.generate(6, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.1,
          0.6 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      ));
    });

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(        appBar: AppBar(
          title: Text('Study Modes - ${widget.deck.name}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Study Mode',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the learning mode that best fits your goals',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildAnimatedCard(
                      0,
                      _StudyModeCard(
                        title: 'Standard Review',
                        description: 'Traditional flashcard review with spaced repetition',
                        icon: Icons.credit_card,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => _startStandardReview(context),
                      ),
                    ),
                    _buildAnimatedCard(
                      1,
                      _StudyModeCard(
                        title: 'Quiz Mode',
                        description: 'Multiple choice questions to test your knowledge',
                        icon: Icons.quiz,
                        color: Colors.green,
                        onTap: () => _startQuizMode(context),
                      ),
                    ),
                    _buildAnimatedCard(
                      2,
                      _StudyModeCard(
                        title: 'Speed Round',
                        description: 'Quick-fire questions for rapid learning',
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        onTap: () => _startSpeedRound(context),
                      ),
                    ),
                    _buildAnimatedCard(
                      3,
                      _StudyModeCard(
                        title: 'Matching Game',
                        description: 'Match front and back sides of cards',
                        icon: Icons.gamepad,
                        color: Colors.purple,
                        onTap: () => _startMatchingGame(context),
                      ),
                    ),
                    _buildAnimatedCard(
                      4,
                      _StudyModeCard(
                        title: 'Writing Practice',
                        description: 'Type answers to improve retention',
                        icon: Icons.edit,
                        color: Colors.blue,
                        onTap: () => _startWritingPractice(context),
                      ),
                    ),
                    _buildAnimatedCard(
                      5,
                      _StudyModeCard(
                        title: 'Reverse Mode',
                        description: 'Study cards from back to front',
                        icon: Icons.flip,
                        color: Colors.teal,
                        onTap: () => _startReverseMode(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  void _startStandardReview(BuildContext context) {
    context.goNamed('review', extra: widget.deck);
  }

  void _startQuizMode(BuildContext context) {
    context.goNamed('quizMode', extra: widget.deck);
  }

  void _startSpeedRound(BuildContext context) {
    context.goNamed('speedRound', extra: widget.deck);
  }

  void _startMatchingGame(BuildContext context) {
    context.goNamed('matchingGame', extra: widget.deck);
  }

  void _startWritingPractice(BuildContext context) {
    context.goNamed('writingPractice', extra: widget.deck);
  }
  void _startReverseMode(BuildContext context) {
    context.goNamed('reverseReview', extra: widget.deck);
  }
}

class _StudyModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StudyModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
