import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashcards_app/viewmodels/statistics_viewmodel.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/ui/components/loading_overlay.dart';
import 'package:flashcards_app/ui/components/primary_button.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatisticsViewModel(
        getAllDecksUseCase: context.read<GetDecksUseCase>(),
        getCardsByDeckUseCase: context.read<GetCardsByDeckUseCase>(),
      ),
      child: const _StatisticsContent(),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            actions: [
              IconButton(
                onPressed: viewModel.refresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Statistics',
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: viewModel.hasError
                ? _buildErrorState(context, viewModel)
                : _buildStatisticsContent(context, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, StatisticsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load statistics',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: viewModel.refresh,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(BuildContext context, StatisticsViewModel viewModel) {
    final data = viewModel.statisticsData;
    if (data == null) {
      return const Center(
        child: Text('No statistics available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(context, data),
          const SizedBox(height: 24),
          _buildProgressChart(context, data),
          const SizedBox(height: 24),
          _buildDecksStats(context, data),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, StatisticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Decks',
                value: '${data.totalDecks}',
                icon: Icons.folder,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Cards',
                value: '${data.totalCards}',
                icon: Icons.style,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Study Streak',
                value: '${data.studyStreak} days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Accuracy',
                value: '${(data.averageAccuracy * 100).toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressChart(BuildContext context, StatisticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Progress',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.recentSessions.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.cardsStudied.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecksStats(BuildContext context, StatisticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deck Statistics',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.deckStats.length,
          itemBuilder: (context, index) {
            final deckStat = data.deckStats[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          deckStat.deck.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${deckStat.totalCards} cards',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: deckStat.masteryPercentage,
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mastery: ${(deckStat.masteryPercentage * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
