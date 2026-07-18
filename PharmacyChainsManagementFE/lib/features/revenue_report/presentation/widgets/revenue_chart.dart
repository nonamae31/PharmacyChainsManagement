import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/revenue_report_response.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenueItem> dailyData;

  const RevenueChart({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = dailyData.fold<double>(
      0,
      (prev, element) => element.amount > prev ? element.amount : prev,
    );

    return Semantics(
      label: 'Revenue line chart',
      hint: 'Displays revenue trends over selected dates',
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (dailyData.isNotEmpty ? dailyData.length - 1 : 0).toDouble(),
            minY: 0,
            maxY: maxY * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: dailyData.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.amount);
                }).toList(),
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withAlpha(51),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
