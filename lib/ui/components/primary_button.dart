import 'package:flutter/material.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';

/// A customizable primary button with press animation and consistent design.
class PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
    this.elevation = 4.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.colorScheme.primary;
    final fg = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: Material(
          color: bg,
          elevation: _isPressed ? widget.elevation / 2 : widget.elevation,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(
            padding: widget.padding,
            child: DefaultTextStyle(
              style: DesignSystem.titleMedium.copyWith(color: fg),
              child: IconTheme(
                data: IconThemeData(color: fg),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
