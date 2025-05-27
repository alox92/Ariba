import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashcards_app/services/performance_optimization_service.dart';
import 'package:flashcards_app/services/memory_manager.dart';
import 'package:flashcards_app/services/dependency_manager.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';

class AdvancedPerformanceScreen extends StatefulWidget {
  const AdvancedPerformanceScreen({super.key});

  @override
  State<AdvancedPerformanceScreen> createState() => _AdvancedPerformanceScreenState();
}

class _AdvancedPerformanceScreenState extends State<AdvancedPerformanceScreen> {
  late PerformanceOptimizationService _performanceService;
  late MemoryManager _memoryManager;
  late DependencyManager _dependencyManager;

  @override
  void initState() {
    super.initState();
    _performanceService = context.read<PerformanceOptimizationService>();
    _memoryManager = MemoryManager.instance;
    _dependencyManager = DependencyManager.instance;
  }
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Performance'),
        ),
        body: Consumer<PerformanceOptimizationService>(
          builder: (context, service, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerformanceOverview(service),
                  const SizedBox(height: 24),
                  _buildAnimationSettings(service),
                  const SizedBox(height: 24),
                  _buildImageSettings(service),
                  const SizedBox(height: 24),
                  _buildCacheSettings(service),
                  const SizedBox(height: 24),
                  _buildMemorySettings(service),
                  const SizedBox(height: 24),
                  _buildQuickActions(service),
                  const SizedBox(height: 24),
                  _buildDependencyInfo(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview(PerformanceOptimizationService service) {
    final metrics = service.performanceMetrics;
    final recommendation = service.getPerformanceRecommendation();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (metrics.isNotEmpty) ...[
              _buildMetricRow('Frame Rate', '${metrics['frame_rate']?.toStringAsFixed(1) ?? 'N/A'} FPS'),
              const SizedBox(height: 8),
            ],
            _buildMetricRow('Recommendation', _getRecommendationText(recommendation)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getPerformanceScore(),
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPerformanceColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Performance Score: ${(_getPerformanceScore() * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSettings(PerformanceOptimizationService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animation Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Animations'),
              subtitle: const Text('Disable to improve performance on slower devices'),
              value: service.animationsEnabled,
              onChanged: (value) => service.setAnimationsEnabled(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSettings(PerformanceOptimizationService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Quality',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<ImageQuality>(
              title: const Text('High Quality'),
              subtitle: const Text('Best quality, higher memory usage'),
              value: ImageQuality.high,
              groupValue: service.imageQuality,
              onChanged: (value) => service.setImageQuality(value!),
            ),
            RadioListTile<ImageQuality>(
              title: const Text('Medium Quality'),
              subtitle: const Text('Balanced quality and performance'),
              value: ImageQuality.medium,
              groupValue: service.imageQuality,
              onChanged: (value) => service.setImageQuality(value!),
            ),
            RadioListTile<ImageQuality>(
              title: const Text('Low Quality'),
              subtitle: const Text('Faster loading, lower memory usage'),
              value: ImageQuality.low,
              groupValue: service.imageQuality,
              onChanged: (value) => service.setImageQuality(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSettings(PerformanceOptimizationService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<CacheConfig>(
              title: const Text('Aggressive'),
              subtitle: const Text('Maximum caching for best performance'),
              value: CacheConfig.aggressive,
              groupValue: service.cacheConfig,
              onChanged: (value) => service.setCacheConfig(value!),
            ),
            RadioListTile<CacheConfig>(
              title: const Text('Balanced'),
              subtitle: const Text('Balanced approach (recommended)'),
              value: CacheConfig.balanced,
              groupValue: service.cacheConfig,
              onChanged: (value) => service.setCacheConfig(value!),
            ),
            RadioListTile<CacheConfig>(
              title: const Text('Conservative'),
              subtitle: const Text('Minimal caching to save memory'),
              value: CacheConfig.conservative,
              groupValue: service.cacheConfig,
              onChanged: (value) => service.setCacheConfig(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemorySettings(PerformanceOptimizationService service) {
    final memoryStats = _memoryManager.getMemoryStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Memory Optimization'),
              subtitle: const Text('Enable aggressive memory management'),
              value: service.memoryOptimizationEnabled,
              onChanged: (value) => service.setMemoryOptimizationEnabled(value),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Cache Usage', '${memoryStats.cacheSize}/${memoryStats.maxCacheSize}'),
            const SizedBox(height: 8),
            _buildMetricRow('Cache Utilization', '${(memoryStats.cacheUtilization * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _memoryManager.clearCache();
                _memoryManager.requestGarbageCollection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memory cleared')),
                );
              },
              child: const Text('Clear Memory Cache'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(PerformanceOptimizationService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => service.optimizeForLowEndDevice(),
                    icon: const Icon(Icons.memory),
                    label: const Text('Optimize for Performance'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => service.optimizeForHighEndDevice(),
                    icon: const Icon(Icons.high_quality),
                    label: const Text('Optimize for Quality'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDependencyInfo() {
    if (!_dependencyManager.initialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading dependency information...'),
            ],
          ),
        ),
      );
    }

    final stats = _dependencyManager.getDependencyStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dependencies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Total Dependencies', '${stats.totalDependencies}'),
            const SizedBox(height: 8),
            _buildMetricRow('Core Dependencies', '${stats.coreDependencies}'),
            const SizedBox(height: 8),
            _buildMetricRow('Updates Available', '${stats.dependenciesWithUpdates}'),
            const SizedBox(height: 8),
            _buildMetricRow('Health Score', '${stats.healthScore}%'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final reportPath = await _dependencyManager.exportDependencyReport();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report exported to: $reportPath')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Export Dependency Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getRecommendationText(PerformanceRecommendation recommendation) {
    switch (recommendation) {
      case PerformanceRecommendation.optimizeForPerformance:
        return 'Optimize for Performance';
      case PerformanceRecommendation.balanced:
        return 'Balanced Settings';
      case PerformanceRecommendation.optimizeForQuality:
        return 'Optimize for Quality';
    }
  }
  double _getPerformanceScore() {
    // Calculate a simple performance score based on settings
    double score = 0.0;
      if (_performanceService.animationsEnabled) {
      score += 0.2;
    }
    
    switch (_performanceService.imageQuality) {
      case ImageQuality.high:
        score += 0.3;
        break;
      case ImageQuality.medium:
        score += 0.2;
        break;
      case ImageQuality.low:
        score += 0.1;
        break;
    }
    
    switch (_performanceService.cacheConfig) {
      case CacheConfig.aggressive:
        score += 0.3;
        break;
      case CacheConfig.balanced:
        score += 0.2;
        break;
      case CacheConfig.conservative:
        score += 0.1;
        break;
    }
      if (_performanceService.memoryOptimizationEnabled) {
      score += 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }  Color _getPerformanceColor() {
    final score = _getPerformanceScore();
    if (score >= 0.8) {
      return Colors.green;
    }
    if (score >= 0.6) {
      return Colors.orange;
    }
    return Colors.red;
  }
}
