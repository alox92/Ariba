import 'package:flutter/material.dart';
import 'package:flashcards_app/ui/theme/design_system.dart';

/// A styled input field with label, hint and validation support.
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: DesignSystem.titleMedium
            .copyWith(color: theme.colorScheme.onSurface),
        hintText: hint,
        hintStyle: DesignSystem.bodyMedium
            .copyWith(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      style:
          DesignSystem.bodyMedium.copyWith(color: theme.colorScheme.onSurface),
    );
  }
}
