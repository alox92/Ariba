import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing app dependencies and versions
class DependencyManager {
  static DependencyManager? _instance;
  static DependencyManager get instance => _instance ??= DependencyManager._();
  
  DependencyManager._();

  Map<String, String> _dependencies = {};
  Map<String, DependencyInfo> _dependencyInfo = {};
  bool _initialized = false;

  bool get initialized => _initialized;
  Map<String, String> get dependencies => Map.from(_dependencies);
  Map<String, DependencyInfo> get dependencyInfo => Map.from(_dependencyInfo);

  /// Initialize the dependency manager
  Future<void> initialize() async {
    await _loadDependencies();
    await _checkForUpdates();
    _initialized = true;
  }
  /// Load dependencies from pubspec
  Future<void> _loadDependencies() async {
    try {
      // Core dependencies that we track
      _dependencies = {
        'flutter': '3.19.0', // Current Flutter version
        'dart': '3.3.0', // Current Dart version
        'provider': '^6.1.1',
        'go_router': '^13.2.0',
        'drift': '^2.14.1',
        'shared_preferences': '^2.2.2',
        'flutter_animate': '^4.5.0',
        'cached_network_image': '^3.3.1',
        'fl_chart': '^0.66.2',
        'path_provider': '^2.1.2',
      };

      // Create dependency info
      _dependencyInfo = {
        for (final entry in _dependencies.entries)
          entry.key: DependencyInfo(
            name: entry.key,
            currentVersion: entry.value,
            isCore: _isCorePackage(entry.key),
            description: _getPackageDescription(entry.key),
          )
      };

      if (kDebugMode) {
        print('DependencyManager: Loaded ${_dependencies.length} dependencies');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DependencyManager: Error loading dependencies: $e');
      }
    }
  }

  /// Check for available updates
  Future<void> _checkForUpdates() async {
    // In a real implementation, this would check pub.dev for latest versions
    // For now, we'll simulate some update availability
    
    for (final info in _dependencyInfo.values) {
      // Simulate update checking
      info.hasUpdate = _simulateUpdateCheck(info.name);
      if (info.hasUpdate) {
        info.latestVersion = _simulateLatestVersion(info.currentVersion);
      }
    }
  }

  /// Get dependency by name
  DependencyInfo? getDependency(String name) {
    return _dependencyInfo[name];
  }

  /// Get core dependencies
  List<DependencyInfo> getCoreDependencies() {
    return _dependencyInfo.values.where((info) => info.isCore).toList();
  }

  /// Get dependencies with updates available
  List<DependencyInfo> getDependenciesWithUpdates() {
    return _dependencyInfo.values.where((info) => info.hasUpdate).toList();
  }  /// Get dependency health score (0-100)
  int getDependencyHealthScore() {
    if (_dependencyInfo.isEmpty) {
      return 0;
    }
    
    final totalDeps = _dependencyInfo.length;
    final outdatedDeps = getDependenciesWithUpdates().length;
    final coreDeps = getCoreDependencies().length;
    final outdatedCoreDeps = getCoreDependencies().where((d) => d.hasUpdate).length;
    
    // Core dependencies are weighted more heavily
    final coreHealthScore = coreDeps > 0 ? ((coreDeps - outdatedCoreDeps) / coreDeps) * 70 : 70;
    final generalHealthScore = ((totalDeps - outdatedDeps) / totalDeps) * 30;
    
    return (coreHealthScore + generalHealthScore).round();
  }

  /// Get dependency usage statistics
  DependencyStats getDependencyStats() {
    final total = _dependencyInfo.length;
    final withUpdates = getDependenciesWithUpdates().length;
    final core = getCoreDependencies().length;
    
    return DependencyStats(
      totalDependencies: total,
      dependenciesWithUpdates: withUpdates,
      coreDependencies: core,
      healthScore: getDependencyHealthScore(),
    );
  }

  /// Export dependency report
  Future<String> exportDependencyReport() async {
    final report = {
      'generated_at': DateTime.now().toIso8601String(),
      'total_dependencies': _dependencyInfo.length,
      'health_score': getDependencyHealthScore(),
      'dependencies': _dependencyInfo.map((key, value) => MapEntry(key, {
        'current_version': value.currentVersion,
        'latest_version': value.latestVersion,
        'has_update': value.hasUpdate,
        'is_core': value.isCore,
        'description': value.description,
      })),
    };

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/dependency_report.json');
      await file.writeAsString(jsonEncode(report));
      return file.path;
    } catch (e) {
      throw Exception('Failed to export dependency report: $e');
    }
  }

  /// Refresh dependency information
  Future<void> refresh() async {
    await _loadDependencies();
    await _checkForUpdates();
  }

  /// Check if package is core
  bool _isCorePackage(String name) {
    const corePackages = {
      'flutter',
      'dart',
      'provider',
      'go_router',
      'drift',
      'shared_preferences',
    };
    return corePackages.contains(name);
  }

  /// Get package description
  String _getPackageDescription(String name) {
    const descriptions = {
      'flutter': 'UI toolkit for building natively compiled applications',
      'dart': 'Programming language optimized for apps on multiple platforms',
      'provider': 'State management solution for Flutter',
      'go_router': 'Declarative router for Flutter',
      'drift': 'Reactive persistence library for Flutter and Dart',
      'shared_preferences': 'Flutter plugin for reading and writing simple key-value pairs',
      'flutter_animate': 'Animation library for Flutter',
      'cached_network_image': 'Flutter library to load and cache network images',
      'fl_chart': 'Powerful chart library for Flutter',
      'package_info_plus': 'Flutter plugin for querying information about the application package',
      'path_provider': 'Flutter plugin for finding commonly used locations on the filesystem',
    };
    return descriptions[name] ?? 'Flutter package';
  }

  /// Simulate update checking (in real app, would use pub.dev API)
  bool _simulateUpdateCheck(String name) {
    // Simulate that 30% of packages have updates
    return name.hashCode % 10 < 3;
  }

  /// Simulate latest version (in real app, would fetch from pub.dev)
  String _simulateLatestVersion(String currentVersion) {
    // Simple version bump simulation
    if (currentVersion.contains('.')) {
      final parts = currentVersion.replaceAll('^', '').split('.');
      if (parts.length >= 3) {
        final patch = int.tryParse(parts[2]) ?? 0;
        return '^${parts[0]}.${parts[1]}.${patch + 1}';
      }
    }
    return currentVersion;
  }
}

/// Information about a dependency
class DependencyInfo {
  final String name;
  final String currentVersion;
  final bool isCore;
  final String description;
  
  String? latestVersion;
  bool hasUpdate = false;

  DependencyInfo({
    required this.name,
    required this.currentVersion,
    required this.isCore,
    required this.description,
    this.latestVersion,
    this.hasUpdate = false,
  });
}

/// Dependency statistics
class DependencyStats {
  final int totalDependencies;
  final int dependenciesWithUpdates;
  final int coreDependencies;
  final int healthScore;

  const DependencyStats({
    required this.totalDependencies,
    required this.dependenciesWithUpdates,
    required this.coreDependencies,
    required this.healthScore,
  });

  @override
  String toString() {
    return 'DependencyStats(total: $totalDependencies, updates: $dependenciesWithUpdates, core: $coreDependencies, health: $healthScore%)';
  }
}
