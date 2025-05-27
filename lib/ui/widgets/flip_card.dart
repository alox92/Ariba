import 'dart:math';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool showBackView;
  final VoidCallback? onFlip;
  final Duration duration;
  final Axis flipDirection;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.showBackView = false,
    this.onFlip,
    this.duration = const Duration(milliseconds: 500),
    this.flipDirection = Axis.horizontal,
  });

  @override
  FlipCardState createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBackView = false;

  @override
  void initState() {
    super.initState();
    _showBackView = widget.showBackView;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_showBackView) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBackView != oldWidget.showBackView) {
      _showBackView = widget.showBackView;
      if (_showBackView) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_controller.isAnimating) {
      return;
    }

    if (_controller.value == 0.0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    _showBackView = !_showBackView;
    if (widget.onFlip != null) {
      widget.onFlip!();
    }
  }

  bool get isFront => _controller.value < 0.5;
  bool get isBack => !isFront;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final Matrix4 frontRotation;
        final Matrix4 backRotation;

        if (widget.flipDirection == Axis.horizontal) {
          frontRotation = Matrix4.identity()..rotateY(angle);
          backRotation = Matrix4.identity()..rotateY(angle - pi);
        } else {
          frontRotation = Matrix4.identity()..rotateX(angle);
          backRotation = Matrix4.identity()..rotateX(angle - pi);
        }

        return Stack(
          children: [
            // Face arrière
            Visibility(
              visible: _animation.value >= 0.5,
              child: Transform(
                transform: backRotation,
                alignment: Alignment.center,
                child: Container(
                  child: widget.back,
                ),
              ),
            ),
            // Face avant
            Visibility(
              visible: _animation.value < 0.5,
              child: Transform(
                transform: frontRotation,
                alignment: Alignment.center,
                child: Container(
                  child: widget.front,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
