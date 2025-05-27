import 'package:flutter/material.dart';

/// Displays a semi-transparent loading overlay over its child when [isLoading] is true.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withAlpha(150), // Replaced withOpacity with withAlpha
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
