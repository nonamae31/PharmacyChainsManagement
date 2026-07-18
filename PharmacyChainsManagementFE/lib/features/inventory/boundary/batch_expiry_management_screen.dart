import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class BatchExpiryManagementScreen extends StatefulWidget {
  const BatchExpiryManagementScreen({super.key});

  @override
  State<BatchExpiryManagementScreen> createState() => _BatchExpiryManagementScreenState();
}

class _BatchExpiryManagementScreenState extends State<BatchExpiryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _batches = [
    {
      'lotNo': 'LOT-2026-GSK-081',
      'medicineName': 'Panadol Extra 500mg',
      'sku': 'SKU-A001',
      'mfgDate': '2026-01-15',
      'expDate': '2029-01-15',
      'currentQty': 1200,
      'unit': 'boxes',
      'supplier': 'GSK Vietnam',
      'coaStatus': 'Verified (Đã đạt COA lab)',
      'recallStatus': 'Safe (An toàn)',
      'warehouseZone': 'Zone A - Rack 04 - Bin B',
    },
    {
      'lotNo': 'LOT-2025-PFI-112',
      'medicineName': 'Amoxicillin 500mg Capsules',
      'sku': 'SKU-B002',
      'mfgDate': '2025-06-10',
      'expDate': '2027-06-10',
      'currentQty': 450,
      'unit': 'boxes',
      'supplier': 'Pfizer Vietnam',
      'coaStatus': 'Verified',
      'recallStatus': 'Safe (An toàn)',
      'warehouseZone': 'Zone B - Rack 01 - Bin C',
    },
    {
      'lotNo': 'LOT-2023-VC09',
      'medicineName': 'Vitamin C Sủi 1000mg',
      'sku': 'SKU-V003',
      'mfgDate': '2023-07-20',
      'expDate': '2026-07-20',
      'currentQty': 45,
      'unit': 'tubes',
      'supplier': 'Sanofi Aventis',
      'coaStatus': 'Verified',
      'recallStatus': 'Alert: Near Expiry',
      'warehouseZone': 'Quarantine Zone Q - Shelf 02',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _batches.where((item) =>
        item['lotNo'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item['medicineName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item['sku'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Batch Traceability & Tracking (Tra cứu Số lô & Hạn sử dụng)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lot Traceability Matrix (Hệ thống truy xuất nguồn gốc số lô)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                        SizedBox(height: 4),
                        Text('Quick lookup for Lot/Batch Number, Manufacturing Date (MFG), Expiry Date (EXP), warehouse location, and GSP COA status (Tra cứu nhanh số Lô, Ngày sản xuất, Hạn sử dụng, vị trí kho và COA).', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Lot Register (Danh mục Số Lô Đang Lưu Hành)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Container(
                  width: 380,
                  height: 42,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(hintText: 'Enter Lot No, SKU or Medicine Name (Nhập số Lot, SKU hoặc Tên thuốc)...', hintStyle: TextStyle(color: AppColors.textHint, fontSize: 12), border: InputBorder.none, isDense: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...filtered.map((item) {
              final isNearExp = item['recallStatus'].toString().contains('Alert') || item['recallStatus'].toString().contains('Near');
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(20)),
                                child: Text(item['lotNo'], style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 12),
                              Text('${item['medicineName']} (${item['sku']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: isNearExp ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(item['recallStatus'], style: TextStyle(color: isNearExp ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('MFG Date (Ngày SX): ${item['mfgDate']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          const SizedBox(width: 24),
                          Text('EXP Date (Hạn SD): ${item['expDate']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isNearExp ? AppColors.error : AppColors.textPrimary)),
                          const SizedBox(width: 24),
                          Text('Current Stock (Tồn hiện tại): ${item['currentQty']} ${item['unit']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text('Warehouse Location (Vị trí kho): ${item['warehouseZone']}  |  COA: ${item['coaStatus']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
