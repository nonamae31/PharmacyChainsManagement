import 'package:flutter/material.dart';

class RevenueSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;

  const RevenueSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Revenue summary: Total Revenue is \$${totalRevenue.toStringAsFixed(2)} and Total Orders is $totalOrders',
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                context,
                title: 'Total Revenue',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _buildSummaryItem(
                context,
                title: 'Total Orders',
                value: totalOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}
