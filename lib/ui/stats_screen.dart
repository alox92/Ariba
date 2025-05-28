import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math'; // Import manquant
import 'package:intl/intl.dart';
import 'package:flashcards_app/viewmodels/stats_viewmodel.dart';
// import '../../data/models/review_stats.dart'; // Pour ReviewStatsData - Removed unused import
import 'package:flashcards_app/data/models/daily_aggregated_stats.dart'; // Import the new model

class StatsScreen extends StatefulWidget {
  final int? deckId; // Rendu optionnel
  final String? deckName; // Rendu optionnel

  const StatsScreen({super.key, this.deckId, this.deckName});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

// Removed SingleTickerProviderStateMixin as _tabController is removed
class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();

    // Chargement des statistiques lors de l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<StatsViewModel>(context, listen: false);
      if (widget.deckId != null) {
        viewModel.loadStatsForDeck(widget.deckId!);
      } else {
        viewModel
            .loadGlobalStats(); // Charger des stats globales si pas de deckId
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatsViewModel>();
    final String title = widget.deckId != null
        ? 'Statistiques pour ${widget.deckName ?? "Paquet Inconnu"}'
        : 'Statistiques Globales';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, StatsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Erreur: ${viewModel.error}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (widget.deckId == null && viewModel.globalDeckCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun paquet trouvé. Créez un paquet pour voir les statistiques.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (widget.deckId != null &&
        viewModel.cardsInDeck == 0 &&
        viewModel.reviewCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucune carte ou révision pour ce paquet. Commencez à étudier pour voir les statistiques.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.deckId != null) ...[
            _buildStatCard('Cartes dans le paquet',
                viewModel.cardsInDeck.toString(), Icons.style),
            const SizedBox(height: 16),
            _buildStatCard('Nombre total de révisions',
                viewModel.reviewCount.toString(), Icons.rate_review),
            const SizedBox(height: 16),
            _buildStatCard(
                'Réussites moyennes',
                '${(viewModel.averageSuccessRate * 100).toStringAsFixed(1)}%',
                Icons.check_circle_outline),
            const SizedBox(height: 16),
            if (viewModel.upcomingReviews.isNotEmpty)
              _buildUpcomingReviews(context, viewModel.upcomingReviews),
            const SizedBox(height: 16),
            if (viewModel.aggregatedReviewStatsByDay
                .isNotEmpty) // Use new aggregated data
              _buildReviewsOverTimeChart(
                  context, viewModel.aggregatedReviewStatsByDay),
            const SizedBox(height: 16),
            if (viewModel.easeFactorDistribution.isNotEmpty)
              _buildEaseFactorDistributionChart(
                  context, viewModel.easeFactorDistribution),
            // Ajoutez d'autres graphiques et statistiques ici
          ] else ...[
            // Afficher les statistiques globales
            _buildStatCard(
                'Nombre total de paquets',
                viewModel.globalDeckCount.toString(),
                Icons.inventory_2_outlined),
            const SizedBox(height: 16),
            _buildStatCard('Nombre total de cartes',
                viewModel.globalCardCount.toString(), Icons.style_outlined),
            const SizedBox(height: 16),
            _buildStatCard(
                'Total des révisions (tous paquets)',
                viewModel.globalReviewCount.toString(),
                Icons.rate_review_outlined),
            const SizedBox(height: 16),
            // Potentiellement un graphique global ou un résumé des activités futures
            if (viewModel.globalUpcomingReviewsCount > 0)
              _buildStatCard(
                  'Révisions à venir (tous paquets)',
                  viewModel.globalUpcomingReviewsCount.toString(),
                  Icons.event_note),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez un paquet pour voir ses statistiques détaillées.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Icon(icon,
                size: 40.0, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4.0),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingReviews(
      BuildContext context, Map<String, int> upcomingReviews) {
    if (upcomingReviews.isEmpty) {
      return const SizedBox.shrink();
    }
    // Trier pour affichage cohérent
    final sortedEntries = upcomingReviews.entries.toList()
      ..sort((a, b) {
        const order = {
          'Demain': 1,
          'Ds 2j': 2,
          'Ds 3j': 3,
          'Ds 4j': 4,
          'Ds 5j': 5,
          'Ds 6j': 6,
          'Ds 7j': 7,
          '> 1 sem': 8,
          '> 2 sem': 9,
          '> 1 mois': 10
        };
        return (order[a.key] ?? 99).compareTo(order[b.key] ?? 99);
      });

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Révisions à venir',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (sortedEntries.isNotEmpty
                              ? sortedEntries.map((e) => e.value).reduce(max)
                              : 0)
                          .toDouble() +
                      2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) =>
                          Theme.of(context).colorScheme.primary.withAlpha(
                              204), // Replaced tooltipBgColor with getTooltipColor
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final String label = sortedEntries[groupIndex].key;
                        return BarTooltipItem(
                          '$label\n${rod.toY.round()}',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedEntries.length) {
                            // Afficher le label pour chaque barre
                            return SideTitleWidget(
                              meta: meta, // Pass the meta object
                              space: 4.0, // Espace entre titre et axe
                              child: Text(sortedEntries[index].key,
                                  style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30, // Espace réservé pour les titres
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, TitleMeta meta) {
                          // Ensure TitleMeta type for meta
                          return SideTitleWidget(
                            meta: meta, // Pass the meta object
                            space: 4.0,
                            child: Text(value.toInt().toString(),
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        ),
                    rightTitles: const AxisTitles(
                        ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedEntries.length, (index) {
                    final entry = sortedEntries[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4))
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsOverTimeChart(
      BuildContext context, List<DailyAggregatedStats> aggregatedStats) {
    if (aggregatedStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<FlSpot> spots = [];
    final Map<int, String> bottomTitles = {};

    // Data is already sorted by date from DAO
    // aggregatedStats.sort((a, b) => a.date.compareTo(b.date)); // No longer needed if DAO sorts

    for (int i = 0; i < aggregatedStats.length; i++) {
      final stat = aggregatedStats[i];
      spots.add(FlSpot(i.toDouble(),
          stat.reviewCount.toDouble())); // Plot review count per day

      // Show date labels for first, last, and some intermediate points
      if (i == 0 ||
          i == aggregatedStats.length - 1 ||
          i % (aggregatedStats.length ~/ 5).clamp(1, aggregatedStats.length) ==
              0) {
        bottomTitles[i] = DateFormat('dd/MM').format(stat.date);
      }
    }

    const double minY = 0;
    // Calculate maxY based on review counts
    double maxY =
        aggregatedStats.map((s) => s.reviewCount).reduce(max).toDouble() + 2;
    if (maxY <= minY) {
      maxY = minY + 5; // Ensure maxY is always greater than minY
    }

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Révisions par jour',
                style:
                    Theme.of(context).textTheme.headlineSmall), // Updated title
            const SizedBox(height: 12.0),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval:
                            1, // Peut nécessiter ajustement selon le nombre de points
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          // Afficher le titre si présent dans la map
                          if (bottomTitles.containsKey(index)) {
                            return SideTitleWidget(
                                meta: meta, // Pass the meta object
                                space: 4,
                                child: Text(bottomTitles[index]!,
                                    style: const TextStyle(fontSize: 10)));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      // Ajustement de l'intervalle pour l'axe Y
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 5 > 1
                            ? ((maxY - minY) / 5)
                                .roundToDouble()
                                .clamp(1, 10000)
                            : 1,
                        getTitlesWidget: (value, TitleMeta meta) {
                          // Ensure TitleMeta type for meta
                          return SideTitleWidget(
                            meta: meta, // Pass the meta object
                            space: 4.0,
                            child: Text(value.toInt().toString(),
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        ),
                    rightTitles: const AxisTitles(
                        ),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                          show: false), // Cacher les points si trop nombreux
                      belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.secondary.withAlpha(
                              51)), // Replaced withOpacity(0.2) with withAlpha(51)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEaseFactorDistributionChart(
      BuildContext context, Map<String, int> easeFactors) {
    if (easeFactors.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convertir les clés en double pour être compatible avec PieChartSectionData
    final Map<double, int> convertedMap = {};
    easeFactors.forEach((key, value) {
      try {
        convertedMap[double.parse(key)] = value;
      } catch (e) {
        // Ignorer les clés qui ne peuvent pas être converties en double
      }
    });

    final List<PieChartSectionData> sections =
        convertedMap.entries.map((entry) {
      const fontSize = 10.0; // Simplified as isTouched was always false
      const radius = 50.0; // Simplified as isTouched was always false
      final colorIndex =
          (entry.key * 10).toInt().abs() % Colors.primaries.length;
      final color = Colors.primaries[colorIndex];

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key.toStringAsFixed(1)}\n(${entry.value})',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
          shadows: [Shadow(blurRadius: 2)],
        ),
      );
    }).toList();

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribution des Facteurs d\'Aisance',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Gérer l'interaction tactile ici si nécessaire
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
