import 'package:flutter/material.dart';

/// A button that animates on hover and press (scale effect).
class IconButtonAnimated extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double size;

  const IconButtonAnimated({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
  });

  @override
  State<IconButtonAnimated> createState() => _IconButtonAnimatedState();
}

class _IconButtonAnimatedState extends State<IconButtonAnimated> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _onEnter(PointerEvent _) => setState(() => _isHovered = true);
  void _onExit(PointerEvent _) => setState(() => _isHovered = false);

  void _onTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double scale = _isPressed ? 0.9 : (_isHovered ? 1.1 : 1.0);
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.primary,
                  size: widget.size,
                ),
                child: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
