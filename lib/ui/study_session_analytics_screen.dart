import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';

class StudySessionAnalyticsScreen extends StatefulWidget {
  final String deckName;
  final int deckId;

  const StudySessionAnalyticsScreen({
    super.key,
    required this.deckName,
    required this.deckId,
  });

  @override
  State<StudySessionAnalyticsScreen> createState() => _StudySessionAnalyticsScreenState();
}

class _StudySessionAnalyticsScreenState extends State<StudySessionAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - In a real app, this would come from a database
  final List<StudySessionData> _sessions = [
    StudySessionData(
      date: DateTime.now().subtract(const Duration(days: 0)),
      mode: 'Quiz Mode',
      score: 85,
      totalQuestions: 20,
      timeSpent: const Duration(minutes: 12),
      accuracy: 0.85,
    ),
    StudySessionData(
      date: DateTime.now().subtract(const Duration(days: 1)),
      mode: 'Speed Round',
      score: 78,
      totalQuestions: 25,
      timeSpent: const Duration(minutes: 2),
      accuracy: 0.76,
    ),
    StudySessionData(
      date: DateTime.now().subtract(const Duration(days: 2)),
      mode: 'Writing Practice',
      score: 92,
      totalQuestions: 15,
      timeSpent: const Duration(minutes: 18),
      accuracy: 0.93,
    ),
    StudySessionData(
      date: DateTime.now().subtract(const Duration(days: 3)),
      mode: 'Matching Game',
      score: 88,
      totalQuestions: 16,
      timeSpent: const Duration(minutes: 8),
      accuracy: 0.88,
    ),
    StudySessionData(
      date: DateTime.now().subtract(const Duration(days: 4)),
      mode: 'Quiz Mode',
      score: 76,
      totalQuestions: 20,
      timeSpent: const Duration(minutes: 15),
      accuracy: 0.76,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics - ${widget.deckName}'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.timeline), text: 'Progress'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Performance'),
              Tab(icon: Icon(Icons.insights), text: 'Insights'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProgressTab(),
            _buildPerformanceTab(),
            _buildInsightsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildProgressChart(),
          const SizedBox(height: 24),
          _buildRecentSessions(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalSessions = _sessions.length;
    final avgAccuracy = _sessions.isNotEmpty 
        ? _sessions.map((s) => s.accuracy).reduce((a, b) => a + b) / _sessions.length 
        : 0.0;
    final totalTimeSpent = _sessions.fold<Duration>(
      Duration.zero, 
      (sum, session) => sum + session.timeSpent,
    );

    return Row(
      children: [
        Expanded(child: _buildStatsCard('Total Sessions', '$totalSessions', Icons.access_time, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatsCard('Avg Accuracy', '${(avgAccuracy * 100).round()}%', Icons.track_changes, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatsCard('Time Spent', '${totalTimeSpent.inHours}h ${totalTimeSpent.inMinutes % 60}m', Icons.timer, Colors.orange)),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accuracy Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value * 100).round()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _sessions.length) {
                            final session = _sessions.reversed.toList()[index];
                            return Text('${session.date.day}/${session.date.month}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _sessions.reversed.toList().asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.accuracy);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_sessions.take(5).map((session) => _buildSessionTile(session)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(StudySessionData session) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getScoreColor(session.accuracy).withValues(alpha: 0.2),
        child: Text(
          '${(session.accuracy * 100).round()}%',
          style: TextStyle(
            color: _getScoreColor(session.accuracy),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(session.mode),
      subtitle: Text(
        '${session.score}/${session.totalQuestions} • ${_formatDuration(session.timeSpent)}',
      ),
      trailing: Text(
        '${session.date.day}/${session.date.month}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildModePerformanceChart(),
          const SizedBox(height: 24),
          _buildTimeAnalysis(),
          const SizedBox(height: 24),
          _buildDifficultyBreakdown(),
        ],
      ),
    );
  }

  Widget _buildModePerformanceChart() {
    final modeData = <String, List<double>>{};
    
    for (final session in _sessions) {
      if (!modeData.containsKey(session.mode)) {
        modeData[session.mode] = [];
      }
      modeData[session.mode]!.add(session.accuracy);
    }

    final modeAverages = modeData.map((mode, accuracies) {
      final avg = accuracies.reduce((a, b) => a + b) / accuracies.length;
      return MapEntry(mode, avg);
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance by Study Mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final modes = modeAverages.keys.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < modes.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                modes[index].replaceAll(' ', '\n'),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value * 100).round()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: modeAverages.entries.toList().asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: _getScoreColor(entry.value.value),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalysis() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeMetric('Average Session Time', _calculateAverageSessionTime()),
            _buildTimeMetric('Total Study Time', _calculateTotalStudyTime()),
            _buildTimeMetric('Most Productive Hour', 'Afternoon (2-4 PM)'),
            _buildTimeMetric('Study Streak', '5 days'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficulty Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDifficultyBar('Easy Cards', 0.92, Colors.green),
            _buildDifficultyBar('Medium Cards', 0.78, Colors.orange),
            _buildDifficultyBar('Hard Cards', 0.65, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBar(String label, double accuracy, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${(accuracy * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: accuracy,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInsightCard(
            'Best Performing Mode',
            'Writing Practice',
            '93% average accuracy',
            Icons.edit,
            Colors.green,
            'You excel at writing practice! Keep focusing on this mode.',
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Area for Improvement',
            'Speed Round',
            '76% average accuracy',
            Icons.flash_on,
            Colors.orange,
            'Try slowing down and focusing on accuracy over speed.',
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Consistency',
            'Study Streak',
            '5 days in a row',
            Icons.local_fire_department,
            Colors.blue,
            'Great consistency! Aim for 7 days to build a strong habit.',
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Time Optimization',
            'Peak Performance',
            'Afternoon sessions',
            Icons.schedule,
            Colors.purple,
            'Your best scores come from afternoon study sessions.',
          ),
          const SizedBox(height: 24),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String subtitle, String metric, IconData icon, Color color, String insight) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$subtitle • $metric',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationTile(
              'Focus on Speed Round practice',
              'Your accuracy in speed rounds is lower than other modes',
              Icons.flash_on,
            ),
            _buildRecommendationTile(
              'Maintain your writing practice streak',
              'You\'re excelling at this mode - keep it up!',
              Icons.trending_up,
            ),
            _buildRecommendationTile(
              'Study during afternoon hours',
              'Your performance peaks between 2-4 PM',
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(String title, String description, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(description),
      contentPadding: EdgeInsets.zero,
    );
  }  Color _getScoreColor(double accuracy) {
    if (accuracy >= 0.9) {
      return Colors.green;
    }
    if (accuracy >= 0.8) {
      return Colors.lightGreen;
    }
    if (accuracy >= 0.7) {
      return Colors.orange;
    }
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }  String _calculateAverageSessionTime() {
    if (_sessions.isEmpty) {
      return '0m';
    }
    final total = _sessions.fold<Duration>(Duration.zero, (sum, session) => sum + session.timeSpent);
    final average = Duration(milliseconds: total.inMilliseconds ~/ _sessions.length);
    return _formatDuration(average);
  }

  String _calculateTotalStudyTime() {
    final total = _sessions.fold<Duration>(Duration.zero, (sum, session) => sum + session.timeSpent);
    return _formatDuration(total);
  }
}

class StudySessionData {
  final DateTime date;
  final String mode;
  final int score;
  final int totalQuestions;
  final Duration timeSpent;
  final double accuracy;

  StudySessionData({
    required this.date,
    required this.mode,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.accuracy,
  });
}
