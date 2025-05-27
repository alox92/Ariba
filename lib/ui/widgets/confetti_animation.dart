import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final bool play;
  final Duration duration;

  const ConfettiAnimation({
    super.key,
    required this.play,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Confetti> _confettis = [];
  final int _confettiCount = 50;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _generateConfettis();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Réinitialiser pour la prochaine utilisation
        _controller.reset();
        _generateConfettis();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateConfettis() {
    // Check if context is available and mounted before accessing MediaQuery
    if (!mounted) {
      return;
    }
    final screenWidth =
        MediaQuery.sizeOf(context).width; // Use MediaQuery.sizeOf

    _confettis = List.generate(_confettiCount, (index) {
      return Confetti(
        color: _getRandomColor(),
        position: Offset(
          _random.nextDouble() * screenWidth,
          -20.0 - _random.nextDouble() * 50.0,
        ),
        size: 8.0 + _random.nextDouble() * 6.0,
        speed: 200.0 + _random.nextDouble() * 300.0,
        angle: _random.nextDouble() * pi / 1.5 - pi / 3.0,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Check if context is available and mounted before accessing MediaQuery
          if (!mounted) {
            return const SizedBox.shrink();
          }
          return CustomPaint(
            painter: ConfettiPainter(
              confettis: _confettis,
              progress: _controller.value,
              deviceSize: MediaQuery.sizeOf(context), // Use MediaQuery.sizeOf
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Confetti {
  Color color;
  Offset position;
  double size;
  double speed;
  double angle;

  Confetti({
    required this.color,
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confettis;
  final double progress;
  final Size deviceSize;

  ConfettiPainter({
    required this.confettis,
    required this.progress,
    required this.deviceSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var confetti in confettis) {
      // Calculer la position actuelle basée sur la progression
      final currentPosition = Offset(
        confetti.position.dx +
            sin(confetti.angle * 5 * progress) * 50.0 * progress,
        confetti.position.dy + confetti.speed * progress,
      );

      // Ne dessiner que si c'est à l'intérieur de l'écran
      if (currentPosition.dy < deviceSize.height) {
        paint.color = confetti.color.withAlpha((255 * (1.0 - progress * 0.5))
            .round()
            .clamp(0, 255)); // Replaced withOpacity with withAlpha

        // Dessiner avec une rotation
        canvas.save();
        canvas.translate(currentPosition.dx, currentPosition.dy);
        canvas.rotate(progress * 10 * pi);

        // Forme aléatoire (cercle, carré ou rectangle)
        final shape = progress * 10 % 3;
        if (shape < 1) {
          canvas.drawCircle(Offset.zero, confetti.size, paint);
        } else if (shape < 2) {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: confetti.size * 2,
              height: confetti.size * 2,
            ),
            paint,
          );
        } else {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: confetti.size * 1.5,
              height: confetti.size * 3,
            ),
            paint,
          );
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
