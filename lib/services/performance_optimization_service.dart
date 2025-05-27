import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app performance optimizations
class PerformanceOptimizationService extends ChangeNotifier {
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _imageQualityKey = 'image_quality';
  static const String _cacheConfigKey = 'cache_config';
  static const String _backgroundProcessingKey = 'background_processing';
  static const String _memoryOptimizationKey = 'memory_optimization';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Performance settings
  bool _animationsEnabled = true;
  ImageQuality _imageQuality = ImageQuality.high;
  CacheConfig _cacheConfig = CacheConfig.balanced;
  bool _backgroundProcessingEnabled = true;
  bool _memoryOptimizationEnabled = false;

  // Performance metrics
  final Map<String, double> _performanceMetrics = {};
  Timer? _metricsTimer;

  // Getters
  bool get initialized => _initialized;
  bool get animationsEnabled => _animationsEnabled;
  ImageQuality get imageQuality => _imageQuality;
  CacheConfig get cacheConfig => _cacheConfig;
  bool get backgroundProcessingEnabled => _backgroundProcessingEnabled;
  bool get memoryOptimizationEnabled => _memoryOptimizationEnabled;
  Map<String, double> get performanceMetrics => Map.from(_performanceMetrics);

  /// Initialize the performance optimization service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    _startPerformanceMonitoring();
    _initialized = true;
    notifyListeners();
  }

  /// Load performance settings from storage
  Future<void> _loadSettings() async {
    _animationsEnabled = _prefs.getBool(_animationsEnabledKey) ?? true;
    _imageQuality = ImageQuality.values[_prefs.getInt(_imageQualityKey) ?? 2];
    _cacheConfig = CacheConfig.values[_prefs.getInt(_cacheConfigKey) ?? 1];
    _backgroundProcessingEnabled = _prefs.getBool(_backgroundProcessingKey) ?? true;
    _memoryOptimizationEnabled = _prefs.getBool(_memoryOptimizationKey) ?? false;
  }

  /// Save performance settings to storage
  Future<void> _saveSettings() async {
    await Future.wait([
      _prefs.setBool(_animationsEnabledKey, _animationsEnabled),
      _prefs.setInt(_imageQualityKey, _imageQuality.index),
      _prefs.setInt(_cacheConfigKey, _cacheConfig.index),
      _prefs.setBool(_backgroundProcessingKey, _backgroundProcessingEnabled),
      _prefs.setBool(_memoryOptimizationKey, _memoryOptimizationEnabled),
    ]);
  }

  /// Toggle animations enabled/disabled
  Future<void> setAnimationsEnabled(bool enabled) async {
    if (_animationsEnabled != enabled) {
      _animationsEnabled = enabled;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Set image quality setting
  Future<void> setImageQuality(ImageQuality quality) async {
    if (_imageQuality != quality) {
      _imageQuality = quality;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Set cache configuration
  Future<void> setCacheConfig(CacheConfig config) async {
    if (_cacheConfig != config) {
      _cacheConfig = config;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Toggle background processing
  Future<void> setBackgroundProcessingEnabled(bool enabled) async {
    if (_backgroundProcessingEnabled != enabled) {
      _backgroundProcessingEnabled = enabled;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Toggle memory optimization
  Future<void> setMemoryOptimizationEnabled(bool enabled) async {
    if (_memoryOptimizationEnabled != enabled) {
      _memoryOptimizationEnabled = enabled;
      await _saveSettings();
      if (enabled) {
        _enableMemoryOptimizations();
      } else {
        _disableMemoryOptimizations();
      }
      notifyListeners();
    }
  }

  /// Get animation duration based on settings
  Duration getAnimationDuration(Duration defaultDuration) {
    if (!_animationsEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Get optimal image cache configuration
  int getImageCacheSize() {
    switch (_imageQuality) {
      case ImageQuality.low:
        return 50; // 50MB
      case ImageQuality.medium:
        return 100; // 100MB
      case ImageQuality.high:
        return 200; // 200MB
    }
  }

  /// Get maximum number of concurrent operations
  int getMaxConcurrentOperations() {
    switch (_cacheConfig) {
      case CacheConfig.aggressive:
        return 10;
      case CacheConfig.balanced:
        return 5;
      case CacheConfig.conservative:
        return 2;
    }
  }

  /// Start monitoring performance metrics
  void _startPerformanceMonitoring() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updatePerformanceMetrics();
    });
  }

  /// Update performance metrics
  void _updatePerformanceMetrics() {
    // Memory usage
    if (PlatformDispatcher.instance.implicitView != null) {
      final view = PlatformDispatcher.instance.implicitView!;
      _performanceMetrics['frame_rate'] = view.display.refreshRate;
    }

    // Add more metrics as needed
    _performanceMetrics['timestamp'] = DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  /// Enable memory optimizations
  void _enableMemoryOptimizations() {
    // Request garbage collection
    if (!kIsWeb) {
      // Only on non-web platforms
      SystemChannels.platform.invokeMethod('System.gc');
    }
  }

  /// Disable memory optimizations
  void _disableMemoryOptimizations() {
    // Restore default settings
  }

  /// Optimize app for low-end devices
  Future<void> optimizeForLowEndDevice() async {
    await Future.wait([
      setAnimationsEnabled(false),
      setImageQuality(ImageQuality.low),
      setCacheConfig(CacheConfig.conservative),
      setMemoryOptimizationEnabled(true),
    ]);
  }

  /// Optimize app for high-end devices
  Future<void> optimizeForHighEndDevice() async {
    await Future.wait([
      setAnimationsEnabled(true),
      setImageQuality(ImageQuality.high),
      setCacheConfig(CacheConfig.aggressive),
      setMemoryOptimizationEnabled(false),
    ]);
  }

  /// Get performance recommendation
  PerformanceRecommendation getPerformanceRecommendation() {
    final frameRate = _performanceMetrics['frame_rate'] ?? 60.0;
    
    if (frameRate < 30) {
      return PerformanceRecommendation.optimizeForPerformance;
    } else if (frameRate > 50) {
      return PerformanceRecommendation.optimizeForQuality;
    }
    
    return PerformanceRecommendation.balanced;
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    super.dispose();
  }
}

enum ImageQuality {
  low,
  medium,
  high,
}

enum CacheConfig {
  conservative,
  balanced,
  aggressive,
}

enum PerformanceRecommendation {
  optimizeForPerformance,
  balanced,
  optimizeForQuality,
}
