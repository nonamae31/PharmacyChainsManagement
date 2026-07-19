import 'package:flutter/material.dart';
import '../../domain/entities/revenue_report_response.dart';

class BranchPerformanceTable extends StatelessWidget {
  final List<BranchPerformanceItem> data;

  const BranchPerformanceTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Branch Performance Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[50]),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                dividerThickness: 1,
                horizontalMargin: 24,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('BRANCH NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  DataColumn(label: Text('REVENUE\n(MTD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  DataColumn(label: Text('VS PREVIOUS\nMONTH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  DataColumn(label: Text('OPERATING\nCOSTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  DataColumn(label: Text('NET\nMARGIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                ],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.branchName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('\$${(item.revenueMtd).toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[800]))),
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              item.vsPreviousMonth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: item.vsPreviousMonth >= 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.vsPreviousMonth >= 0 ? '+' : ''}${item.vsPreviousMonth.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: item.vsPreviousMonth >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text('\$${(item.operatingCosts).toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[800]))),
                      DataCell(Text('${item.netMargin.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[800]))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: _getStatusColor(item.status),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${data.length} active branches',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'STABLE':
        return Colors.green;
      case 'PEAKING':
      case 'FAST GROWTH':
        return Colors.teal;
      case 'REVIEW':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
