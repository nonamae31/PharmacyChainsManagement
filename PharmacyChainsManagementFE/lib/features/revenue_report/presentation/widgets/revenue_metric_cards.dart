import 'package:flutter/material.dart';

class RevenueMetricCards extends StatelessWidget {
  final double totalRevenue;
  final double totalRevenueGrowth;
  final double avgRevenue;
  final double avgRevenueGrowth;
  final String topBranchName;
  final double topBranchRevenue;
  final double forecastQ4;

  const RevenueMetricCards({
    super.key,
    required this.totalRevenue,
    required this.totalRevenueGrowth,
    required this.avgRevenue,
    required this.avgRevenueGrowth,
    required this.topBranchName,
    required this.topBranchRevenue,
    required this.forecastQ4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic width based on screen size to prevent overflow
        int columns = 4;
        if (constraints.maxWidth < 600) {
          columns = 1;
        } else if (constraints.maxWidth < 900) {
          columns = 2;
        }
        final double spacing = 16.0;
        final double width = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _buildCard(
              context: context,
              width: width,
              title: 'TOTAL REVENUE',
              icon: Icons.monetization_on_outlined,
              value: '\$${_formatCurrency(totalRevenue)}',
              subtitle: '${totalRevenueGrowth >= 0 ? '+' : ''}${totalRevenueGrowth.toStringAsFixed(1)}% vs last month',
              isPositive: totalRevenueGrowth >= 0,
            ),
            _buildCard(
              context: context,
              width: width,
              title: 'AVG REVENUE/BRANCH',
              icon: Icons.storefront_outlined,
              value: '\$${_formatCurrency(avgRevenue)}',
              subtitle: '${avgRevenueGrowth >= 0 ? '+' : ''}${avgRevenueGrowth.toStringAsFixed(1)}% vs last month',
              isPositive: avgRevenueGrowth >= 0,
            ),
            _buildCard(
              context: context,
              width: width,
              title: 'TOP BRANCH',
              icon: Icons.emoji_events_outlined,
              value: topBranchName,
              subtitle: '\$${_formatCurrency(topBranchRevenue)} this month',
              isPositive: true,
              subtitleColor: Colors.grey[600],
            ),
            _buildCard(
              context: context,
              width: width,
              title: 'FORECAST Q4',
              icon: Icons.trending_up,
              value: '\$${(forecastQ4 / 1000000).toStringAsFixed(1)}M',
              subtitle: 'On track for targets',
              isPositive: true,
              subtitleColor: Colors.grey[600],
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)},${(value % 1000).toInt().toString().padLeft(3, '0')}';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildCard({
    required BuildContext context,
    required double width,
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required bool isPositive,
    Color? subtitleColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Icon(icon, size: 20, color: Colors.blueGrey),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (subtitleColor == null) ...[
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor ?? (isPositive ? Colors.green : Colors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
