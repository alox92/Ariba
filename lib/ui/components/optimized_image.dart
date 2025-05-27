import 'package:flutter/material.dart';
import 'package:flashcards_app/services/performance_optimization_service.dart';

/// Optimized image widget that adapts to performance settings
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
  }) : assert(imageUrl != null || assetPath != null, 'Either imageUrl or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    final performanceService = context.findAncestorWidgetOfExactType<_PerformanceServiceProvider>();
    final imageQuality = performanceService?.service.imageQuality ?? ImageQuality.high;
    
    Widget image;
    
    if (imageUrl != null) {
      image = _buildNetworkImage(imageQuality);
    } else {
      image = _buildAssetImage(imageQuality);
    }

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    if (backgroundColor != null) {
      image = Container(
        color: backgroundColor,
        child: image,
      );
    }

    return image;
  }
  Widget _buildNetworkImage(ImageQuality quality) {
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: _getOptimalCacheWidth(quality),
      cacheHeight: _getOptimalCacheHeight(quality),      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  Widget _buildAssetImage(ImageQuality quality) {
    return Image.asset(
      assetPath!,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: _getOptimalCacheWidth(quality),
      cacheHeight: _getOptimalCacheHeight(quality),
      errorBuilder: (context, error, stackTrace) => errorWidget ?? _buildDefaultErrorWidget(),
    );
  }
  int? _getOptimalCacheWidth(ImageQuality quality) {
    if (width == null) {
      return null;
    }
    
    switch (quality) {
      case ImageQuality.low:
        return (width! * 0.5).toInt();
      case ImageQuality.medium:
        return (width! * 0.75).toInt();
      case ImageQuality.high:
        return width!.toInt();
    }
  }  int? _getOptimalCacheHeight(ImageQuality quality) {
    if (height == null) {
      return null;
    }
    
    switch (quality) {
      case ImageQuality.low:
        return (height! * 0.5).toInt();
      case ImageQuality.medium:
        return (height! * 0.75).toInt();
      case ImageQuality.high:
        return height!.toInt();
    }
  }
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
      ),
    );
  }
}

/// Provider widget for performance service
class _PerformanceServiceProvider extends InheritedWidget {
  final PerformanceOptimizationService service;

  const _PerformanceServiceProvider({
    required this.service,
    required super.child,
  });

  @override
  bool updateShouldNotify(_PerformanceServiceProvider oldWidget) {
    return service != oldWidget.service;
  }
}

/// Extension to provide performance service to widgets
extension PerformanceServiceExtension on BuildContext {
  PerformanceOptimizationService? get performanceService {
    return dependOnInheritedWidgetOfExactType<_PerformanceServiceProvider>()?.service;
  }
}

/// Wrapper to provide performance service to widget tree
class PerformanceOptimizedApp extends StatelessWidget {
  final PerformanceOptimizationService performanceService;
  final Widget child;

  const PerformanceOptimizedApp({
    super.key,
    required this.performanceService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _PerformanceServiceProvider(
      service: performanceService,
      child: child,
    );
  }
}
