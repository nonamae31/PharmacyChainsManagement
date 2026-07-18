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
      'serialRange': 'SN99887000 - SN99888200 (GS1 2D DataMatrix)',
      'traceabilityTree': 'GSK Factory UK ➔ Customs Clear ➔ QC Passed (Lê Văn Hùng) ➔ Putaway Zone A ➔ Dispatched 200 boxes to Store District 1 & District 3 ➔ 42 units sold to patients via POS.',
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
      'serialRange': 'SN44551000 - SN44551450',
      'traceabilityTree': 'Pfizer Plant Belgium ➔ Air Freight ➔ QC Passed ➔ Putaway Zone B ➔ Allocated to B2B Hospital contracts.',
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
      'recallStatus': 'Alert: Near Expiry (3 days left)',
      'warehouseZone': 'Quarantine Zone Q - Shelf 02',
      'serialRange': 'SN11220001 - SN11220045',
      'traceabilityTree': 'Sanofi Plant France ➔ QC Verified ➔ Putaway Zone C ➔ Transferred to Quarantine Zone Q due to near-expiry alert.',
    },
  ];

  void _showTraceabilityModal(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.account_tree, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(child: Text('End-to-End Pharma Traceability Tree: ${item['lotNo']}')),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${item['medicineName']} (${item['sku']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Serialization Range: ${item['serialRange']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF93C5FD))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔗 Chain of Custody & Lifecycle Roadmap:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                    const SizedBox(height: 10),
                    Text(item['traceabilityTree'], style: const TextStyle(height: 1.6, fontSize: 13, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('✅ Fully verified with GS1 EPCIS serialization protocols. Suitable for rapid targeted recall.', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close Traceability View')),
        ],
      ),
    );
  }

  void _triggerRecall(int index) {
    setState(() {
      _batches[index]['recallStatus'] = '🚨 QUARANTINED - RECALL ACTIVE';
      _batches[index]['warehouseZone'] = 'Quarantine Zone Q - Locked';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Emergency Recall triggered for Batch ${_batches[index]['lotNo']}! All POS sales locked and supplier notified immediately.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
        title: const Text('Batch Traceability & Serialization Tracking (Tra cứu Số lô, Hạn dùng & Serialization)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                        Text('Lot Traceability & Serialization Matrix (Hệ thống truy xuất nguồn gốc & Serialization GS1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                        SizedBox(height: 4),
                        Text('Full genealogy tracking from manufacturer to store shelf and patient. Supports instant quarantine & automated recall execution across branches.', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
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
                const Text('Active Lot & Serialization Register (Danh mục Lô & Serial Đang Lưu Hành)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
            ...filtered.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isNearExp = item['recallStatus'].toString().contains('Alert') || item['recallStatus'].toString().contains('Near') || item['recallStatus'].toString().contains('QUARANTINED');
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 10),
                      Text('GS1 Serialization Range: ${item['serialRange']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 24,
                        runSpacing: 4,
                        children: [
                          Text('MFG Date (Ngày SX): ${item['mfgDate']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          Text('EXP Date (Hạn SD): ${item['expDate']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isNearExp ? AppColors.error : AppColors.textPrimary)),
                          Text('Current Stock (Tồn hiện tại): ${item['currentQty']} ${item['unit']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.info),
                              Text('Warehouse Location: ${item['warehouseZone']}  |  COA: ${item['coaStatus']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showTraceabilityModal(item),
                                icon: const Icon(Icons.account_tree_outlined, size: 16),
                                label: const Text('Traceability Tree (Genealogy)'),
                              ),
                              const SizedBox(width: 8),
                              if (!item['recallStatus'].toString().contains('QUARANTINED'))
                                ElevatedButton.icon(
                                  onPressed: () => _triggerRecall(idx),
                                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                                  label: const Text('Trigger Emergency Recall'),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                                ),
                            ],
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
