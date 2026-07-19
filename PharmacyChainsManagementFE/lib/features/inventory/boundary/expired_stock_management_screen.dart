import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ExpiredStockManagementScreen extends StatefulWidget {
  const ExpiredStockManagementScreen({super.key});

  @override
  State<ExpiredStockManagementScreen> createState() => _ExpiredStockManagementScreenState();
}

class _ExpiredStockManagementScreenState extends State<ExpiredStockManagementScreen> {
  final List<Map<String, dynamic>> _expiredStockList = [
    {
      'sku': 'SKU-V003',
      'name': 'Vitamin C Sủi 1000mg',
      'lotNo': 'LOT-2023-VC09',
      'expiryDate': '2026-07-20',
      'daysRemaining': 2,
      'qty': 45,
      'unit': 'tubes',
      'cost': 1500000,
      'status': 'Critical Expiry (Cận date < 30 ngày)',
      'actionStatus': 'Quarantined (Đã cách ly)',
    },
    {
      'sku': 'SKU-C004',
      'name': 'Cephalexin 500mg Capsules',
      'lotNo': 'LOT-2022-CP01',
      'expiryDate': '2026-06-30',
      'daysRemaining': -18,
      'qty': 12,
      'unit': 'boxes',
      'cost': 1800000,
      'status': 'Expired (Đã hết hạn)',
      'actionStatus': 'Pending Disposal Report (Chờ biên bản tiêu hủy)',
    },
    {
      'sku': 'SKU-A001',
      'name': 'Panadol Extra 500mg (Damaged Outer Box)',
      'lotNo': 'LOT-2025-PN88',
      'expiryDate': '2028-05-15',
      'daysRemaining': 660,
      'qty': 5,
      'unit': 'boxes',
      'cost': 450000,
      'status': 'Damaged (Hư hỏng)',
      'actionStatus': 'Quarantined (Đã cách ly)',
    },
  ];

  void _handleDisposal(int index, String action) {
    setState(() {
      _expiredStockList[index]['actionStatus'] = action;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã thực hiện lệnh [$action] cho sản phẩm ${_expiredStockList[index]['name']}!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expired & Damaged Stock Management (Thuốc Hết hạn & Hư hỏng)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.report_problem, color: AppColors.error, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expiry Risk Management (FEFO) & Disposal (Quản lý rủi ro Hết hạn & Tiêu hủy)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF991B1B))),
                        SizedBox(height: 4),
                        Text('Automatic warnings for near-expiry batches (< 90 days) and quarantine of expired/damaged stock awaiting disposal report (Cảnh báo lô cận date và cách ly thuốc hết hạn/hư hỏng chờ tiêu hủy).', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Near-Expiry / Expired / Damaged Stock List (Danh sách Thuốc Cận Date / Hết hạn / Hư hỏng)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            ..._expiredStockList.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final status = item['status'] as String;
              final actionStatus = item['actionStatus'] as String;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                  side: BorderSide(color: status.contains('Expired') ? AppColors.error : AppColors.warning),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.contains('Expired') ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(status, style: TextStyle(color: status.contains('Expired') ? AppColors.error : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item['name']} (${item['sku']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 2),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                  child: Text('Action Status (Tình trạng xử lý): $actionStatus', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryDark), overflow: TextOverflow.ellipsis, maxLines: 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text('Lot No (Số Lô): ${item['lotNo']} | Expiry Date (Hạn sử dụng): ${item['expiryDate']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                          Text(item['daysRemaining'] < 0 ? 'Expired ${-item['daysRemaining']} days ago! (Đã hết hạn ${-item['daysRemaining']} ngày)' : '${item['daysRemaining']} days remaining (Còn ${item['daysRemaining']} ngày)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item['daysRemaining'] < 0 ? AppColors.error : const Color(0xFFD97706))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Quarantine Qty (Số lượng cách ly): ${item['qty']} ${item['unit']}  •  Estimated Loss Value (Thiệt hại dự kiến): ${(item['cost'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 2),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _handleDisposal(idx, 'Returned to Supplier (Hoàn trả nhà cung cấp)'),
                            icon: const Icon(Icons.reply, size: 18),
                            label: const Text('Return to Supplier (Hoàn trả nhà cung cấp)'),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.info),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _handleDisposal(idx, 'Disposal Report Created (Đã lập biên bản tiêu hủy GSP)'),
                            icon: const Icon(Icons.delete_forever, size: 18),
                            label: const Text('Create Disposal Report (Lập biên bản Tiêu hủy)'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
