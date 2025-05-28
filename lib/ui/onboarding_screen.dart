import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/ui/routes/app_router.dart';
import 'theme/design_system.dart';

/// Onboarding screen with liquid swipe and animated background
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = LiquidController();
  bool _isLast = false;
  int _currentPage = 0;

  void _onChangePageCallback(int page) {
    setState(() {
      _currentPage = page;
      _isLast = page == _pages.length - 1;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      AppRouter.router.go('/');
    }
  }

  List<Widget> get _pages => [
        _buildPage(
          color: DesignSystem.primary,
          title: 'Bienvenue',
          subtitle: 'Bienvenue dans Flashcards App',
          icon: Icons.flash_on,
        ),
        _buildPage(
          color: DesignSystem.secondary,
          title: 'Organisez',
          subtitle: 'Créez et organisez vos paquets',
          icon: Icons.folder_open,
        ),
        _buildPage(
          color: DesignSystem.tertiary,
          title: 'Révisez',
          subtitle: 'Améliorez votre apprentissage',
          icon: Icons.school,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      body: Stack(
        children: [
          _AnimatedBackground(),
          LiquidSwipe(
            pages: pages,
            fullTransitionValue: 600,
            enableLoop: false,
            waveType: WaveType.circularReveal,
            enableSideReveal: true,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            liquidController: _controller,
            onPageChangeCallback: _onChangePageCallback,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () =>
                        _controller.animateToPage(page: _currentPage - 1),
                    child: const Text('Précédent'),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: _isLast
                      ? _finishOnboarding
                      : () => _controller.animateToPage(page: _currentPage + 1),
                  child: Text(_isLast ? 'Commencer' : 'Suivant'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 100, color: DesignSystem.onPrimary)
              .animate()
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            title,
            style: DesignSystem.h1.copyWith(color: DesignSystem.onPrimary),
          ).animate().slideX(begin: -1.0, duration: 800.ms),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style:
                DesignSystem.bodyLarge.copyWith(color: DesignSystem.onPrimary),
          ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
        ],
      ),
    );
  }
}

/// Animated background gradient breathing between two states
class _AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
      colors: const [
        [Color(0xFF6750A4), Color(0xFF7D5260)],
        [Color(0xFF625B71), Color(0xFF4B4453)],
      ],
      duration: 4000.ms,
      curve: Curves.easeInOut,
      child: const SizedBox.expand(),
    );
  }
}

/// Helper widget to animate gradient between given color pairs
class AnimateGradient extends StatefulWidget {
  final List<List<Color>> colors;
  final Widget child;
  final Duration duration;
  final bool repeat;
  final Curve curve;

  const AnimateGradient({
    super.key,
    required this.colors,
    required this.child,
    required this.duration,
    this.repeat = true,
    this.curve = Curves.linear,
  });

  @override
  AnimateGradientState createState() => AnimateGradientState();
}

class AnimateGradientState extends State<AnimateGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final index = _anim.value * (widget.colors.length - 1);
        final lower = widget.colors[index.floor()];
        final upper = widget.colors[index.ceil()];
        final t = index - index.floor();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(lower[0], upper[0], t)!,
                Color.lerp(lower[1], upper[1], t)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
