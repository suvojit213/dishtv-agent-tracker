import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:dishtv_agent_tracker/core/constants/app_colors.dart';
import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:dishtv_agent_tracker/domain/entities/monthly_summary.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_card.dart';

class PerformanceChart extends StatelessWidget {
  final MonthlySummary summary;

  const PerformanceChart({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEntries = List<DailyEntry>.from(summary.entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Chart',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No data available for this month',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    double maxHours = 0;
    int maxCalls = 0;

    for (final entry in sortedEntries) {
      if (entry.totalLoginTimeInHours > maxHours) {
        maxHours = entry.totalLoginTimeInHours;
      }
      if (entry.callCount > maxCalls) {
        maxCalls = entry.callCount;
      }
    }

    maxHours = (maxHours.ceil() + 1).toDouble();
    maxCalls = (maxCalls ~/ 10 + 1) * 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxHours,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor parameter is removed.
                          // The background is now part of the tooltip item's style.
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final entry = sortedEntries[groupIndex];
                            return BarTooltipItem(
                              '${entry.formattedLoginTime}\n${entry.callCount} calls',
                              const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= sortedEntries.length) {
                                return const SizedBox.shrink();
                              }
                              final entry = sortedEntries[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('dd').format(entry.date),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final callValue = (value / maxHours * maxCalls).toInt();
                              return Text(
                                callValue.toString(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dailyEntry = entry.value;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyEntry.totalLoginTimeInHours,
                              color: AppColors.chartBar,
                              width: 12,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      context,
                      'Login Hours',
                      AppColors.chartBar,
                    ),
                    const SizedBox(width: 24),
                    _buildLegendItem(
                      context,
                      'Call Count',
                      AppColors.chartLine,
                      isLine: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context,
      String label,
      Color color, {
        bool isLine = false,
      }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isLine ? Colors.transparent : color,
            border: isLine ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}