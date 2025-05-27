import 'package:flutter/material.dart';
import 'package:flashcards_app/services/theme_service.dart';
import 'dart:math'; // Needed for sin and pi

/// Widget to render animated backgrounds based on user selection.
class BackgroundWidget extends StatefulWidget {
  final BackgroundOption option;
  const BackgroundWidget(this.option, {super.key});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          switch (widget.option) {
            case BackgroundOption.liquidChrome:
              return Container(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.cyanAccent,
                      Colors.blueAccent,
                    ],
                    stops: [0.0, _animation.value, 1.0],
                  ),
                ),
              );
            case BackgroundOption.hyperspace:
              return CustomPaint(
                painter: _StarFieldPainter(_animation.value),
              );
            case BackgroundOption.waveMath:
              return CustomPaint(
                painter: _WavePainter(_animation.value),
              );
            case BackgroundOption.infiniteFractal:
              // Placeholder fractal effect: radial gradient
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.deepPurple, Colors.black],
                    radius: 0.85,
                    focal: Alignment(0.5 * (1 + _animation.value * 2 - 1),
                        0.5 * (1 - _animation.value * 2 + 1)),
                  ),
                ),
              );
            case BackgroundOption.none:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// Simple star field painter
class _StarFieldPainter extends CustomPainter {
  final double progress;
  _StarFieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha((0.7 * 255).round());
    for (int i = 0; i < 100; i++) {
      final x = (size.width * (i / 100) + progress * size.width) % size.width;
      final y = size.height * ((i * 3 % 100) / 100);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) =>
      old.progress != progress;
}

// Wave painter
class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()..color = Colors.teal.withAlpha((0.5 * 255).round());

    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          20 * sin((x / size.width * 2 * pi) + (progress * 2 * pi));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.progress != progress;
}
