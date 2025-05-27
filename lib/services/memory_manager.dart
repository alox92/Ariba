import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Helper class for managing memory usage and optimization
class MemoryManager {
  static MemoryManager? _instance;
  static MemoryManager get instance => _instance ??= MemoryManager._();
  
  MemoryManager._();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  Timer? _cleanupTimer;
  
  static const Duration _defaultCacheTimeout = Duration(minutes: 10);
  static const int _maxCacheSize = 100;

  /// Initialize memory manager
  void initialize() {
    _startCleanupTimer();
  }

  /// Start automatic cache cleanup
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpiredCache();
    });
  }

  /// Cache data with automatic expiration
  void cache(String key, dynamic data, {Duration? timeout}) {
    final expirationTime = DateTime.now().add(timeout ?? _defaultCacheTimeout);
    
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxCacheSize) {
      _removeOldestCacheEntry();
    }
    
    _cache[key] = data;
    _cacheTimestamps[key] = expirationTime;
  }

  /// Retrieve cached data
  T? getCached<T>(String key) {
    final data = _cache[key];
    final timestamp = _cacheTimestamps[key];
    
    if (data != null && timestamp != null) {
      if (DateTime.now().isBefore(timestamp)) {
        return data as T?;
      } else {
        // Data expired, remove it
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    
    return null;
  }

  /// Remove specific cache entry
  void removeCached(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, expiration) {
      if (now.isAfter(expiration)) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
      if (kDebugMode && expiredKeys.isNotEmpty) {
      debugPrint('MemoryManager: Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }  /// Remove the oldest cache entry
  void _removeOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) {
      return;
    }
    
    String? oldestKey;
    DateTime? oldestTime;
    
    _cacheTimestamps.forEach((key, time) {
      if (oldestTime == null || time.isBefore(oldestTime!)) {
        oldestKey = key;
        oldestTime = time;
      }
    });
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Request garbage collection (platform-dependent)
  void requestGarbageCollection() {
    if (!kIsWeb) {
      try {
        SystemChannels.platform.invokeMethod('System.gc');
      } catch (e) {
        if (kDebugMode) {
          print('MemoryManager: Could not request GC: $e');
        }
      }
    }
  }

  /// Optimize memory for low-end devices
  void optimizeForLowEndDevice() {
    // Clear all caches
    clearCache();
    
    // Request garbage collection
    requestGarbageCollection();
    
    if (kDebugMode) {
      print('MemoryManager: Optimized for low-end device');
    }
  }

  /// Get memory usage statistics
  MemoryStats getMemoryStats() {
    return MemoryStats(
      cacheSize: _cache.length,
      maxCacheSize: _maxCacheSize,
      cacheUtilization: _cache.length / _maxCacheSize,
    );
  }

  /// Preload data into cache
  void preload(String key, Future<dynamic> Function() loader, {Duration? timeout}) {
    if (!_cache.containsKey(key)) {
      loader().then((data) {
        cache(key, data, timeout: timeout);
      }).catchError((error) {
        if (kDebugMode) {
          print('MemoryManager: Failed to preload $key: $error');
        }
      });
    }
  }

  /// Create a memory-efficient image cache key
  String createImageCacheKey(String path, {int? width, int? height}) {
    final dimensions = width != null && height != null ? '_${width}x$height' : '';
    return 'image_${path.hashCode}$dimensions';
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    clearCache();
  }
}

/// Memory usage statistics
class MemoryStats {
  final int cacheSize;
  final int maxCacheSize;
  final double cacheUtilization;

  const MemoryStats({
    required this.cacheSize,
    required this.maxCacheSize,
    required this.cacheUtilization,
  });

  @override
  String toString() {
    return 'MemoryStats(cache: $cacheSize/$maxCacheSize, utilization: ${(cacheUtilization * 100).toStringAsFixed(1)}%)';
  }
}
