import 'package:flutter/material.dart';
import 'package:flashcards_app/services/performance_optimization_service.dart';

/// Manager for handling UI animations with performance optimizations
class UIAnimationManager {
  static UIAnimationManager? _instance;
  static UIAnimationManager get instance => _instance ??= UIAnimationManager._();
  
  UIAnimationManager._();

  PerformanceOptimizationService? _performanceService;

  void initialize(PerformanceOptimizationService performanceService) {
    _performanceService = performanceService;
  }

  /// Get optimized animation duration
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_performanceService?.animationsEnabled == false) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Create an optimized fade transition
  Widget createFadeTransition({
    required Widget child,
    required AnimationController controller,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);
    
    if (optimizedDuration == Duration.zero) {
      return child;
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }

  /// Create an optimized slide transition
  Widget createSlideTransition({
    required Widget child,
    required AnimationController controller,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);
    
    if (optimizedDuration == Duration.zero) {
      return child;
    }

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }

  /// Create an optimized scale transition
  Widget createScaleTransition({
    required Widget child,
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);
    
    if (optimizedDuration == Duration.zero) {
      return child;
    }

    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      ),
      child: child,
    );
  }

  /// Create an optimized rotation transition
  Widget createRotationTransition({
    required Widget child,
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);
    
    if (optimizedDuration == Duration.zero) {
      return child;
    }

    return RotationTransition(
      turns: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }

  /// Create an optimized hero transition
  Widget createHeroTransition({
    required String tag,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);
    
    return Hero(
      tag: tag,
      flightShuttleBuilder: optimizedDuration == Duration.zero
          ? (context, animation, direction, fromContext, toContext) => child
          : null,
      child: child,
    );
  }

  /// Create page transitions with performance optimizations
  PageRouteBuilder createPageRoute({
    required Widget child,
    RouteSettings? settings,
    PageTransitionType type = PageTransitionType.slide,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final optimizedDuration = getAnimationDuration(duration);

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: optimizedDuration,
      reverseTransitionDuration: optimizedDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (optimizedDuration == Duration.zero) {
          return child;
        }

        switch (type) {
          case PageTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case PageTransitionType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case PageTransitionType.scale:
            return ScaleTransition(scale: animation, child: child);
          case PageTransitionType.rotation:
            return RotationTransition(turns: animation, child: child);
        }
      },
    );
  }
}

enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
}
