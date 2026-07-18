import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class QcInspectionScreen extends StatefulWidget {
  const QcInspectionScreen({super.key});

  @override
  State<QcInspectionScreen> createState() => _QcInspectionScreenState();
}

class _QcInspectionScreenState extends State<QcInspectionScreen> {
  final List<Map<String, dynamic>> _qcBatches = [
    {
      'batchNo': 'LOT-2026-GSK-081',
      'medicineName': 'Panadol Extra 500mg (200 boxes)',
      'supplier': 'GlaxoSmithKline (GSK)',
      'poNo': 'PO-20260715-01',
      'receivedDate': '2026-07-18',
      'tempCompliance': true,
      'packagingIntact': true,
      'coaVerified': true,
      'status': 'Pending Inspection',
      'inspectorNote': 'Arrived via refrigerated transport (2-8°C zone verified).',
    },
    {
      'batchNo': 'LOT-2026-PFI-112',
      'medicineName': 'Amoxicillin 500mg Capsules (500 boxes)',
      'supplier': 'Pfizer Vietnam',
      'poNo': 'PO-20260714-03',
      'receivedDate': '2026-07-17',
      'tempCompliance': true,
      'packagingIntact': false,
      'coaVerified': true,
      'status': 'Quarantined - Damaged Box',
      'inspectorNote': '3 outer cartons show minor water stain during offloading.',
    },
    {
      'batchNo': 'LOT-2026-SFO-045',
      'medicineName': 'Vitamin C 1000mg Effervescent (300 tubes)',
      'supplier': 'Sanofi Aventis',
      'poNo': 'PO-20260712-09',
      'receivedDate': '2026-07-16',
      'tempCompliance': true,
      'packagingIntact': true,
      'coaVerified': true,
      'status': 'Passed QC',
      'inspectorNote': 'Meets GSP standards. COA Lot matched lab specification.',
    },
  ];

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _qcBatches[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật kết quả QC lô ${_qcBatches[index]['batchNo']} thành: $newStatus'),
        backgroundColor: newStatus.contains('Passed') ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QC Inspection (Kiểm tra chất lượng GSP/GDP)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                  Icon(Icons.fact_check, color: AppColors.primary, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Incoming Quality Inspection Process (Quy trình Kiểm định Chất lượng Đầu vào)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                        SizedBox(height: 4),
                        Text('All incoming batches must be inspected for storage temperature compliance, packaging integrity, and valid Certificate of Analysis (COA) before warehouse entry (Mọi lô thuốc phải kiểm tra nhiệt độ, bao bì và chứng chỉ COA trước khi nhập kho).', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('QC Inspection Batch Queue (Danh sách Lô hàng chờ Kiểm định QC)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            ..._qcBatches.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final status = item['status'] as String;
              Color statusColor = AppColors.warning;
              if (status.contains('Passed')) statusColor = AppColors.success;
              if (status.contains('Quarantine') || status.contains('Rejected')) statusColor = AppColors.error;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                  side: BorderSide(color: AppColors.border),
                ),
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
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              const SizedBox(width: 12),
                              Text(item['batchNo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                            ],
                          ),
                          Text('PO: ${item['poNo']} • Received Date (Ngày nhận): ${item['receivedDate']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item['medicineName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                      const SizedBox(height: 4),
                      Text('Supplier (Nhà cung cấp): ${item['supplier']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const Divider(height: 24, color: AppColors.divider),
                      Row(
                        children: [
                          _buildCheckItem('GSP Temperature Compliance (Nhiệt độ bảo quản GSP)', item['tempCompliance']),
                          const SizedBox(width: 24),
                          _buildCheckItem('Intact Packaging (Bao bì nguyên vẹn)', item['packagingIntact']),
                          const SizedBox(width: 24),
                          _buildCheckItem('Valid COA (COA hợp lệ)', item['coaVerified']),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Inspector Note (Ghi chú Kiểm định): ${item['inspectorNote']}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status != 'Rejected')
                            OutlinedButton.icon(
                              onPressed: () => _updateStatus(idx, 'Rejected - Return to Supplier'),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Reject & Return (Từ chối & Hoàn trả)'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            ),
                          const SizedBox(width: 12),
                          if (status != 'Passed QC')
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus(idx, 'Passed QC - Ready for Storage'),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Pass QC & Approve (Duyệt đạt chuẩn QC)'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
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

  Widget _buildCheckItem(String label, bool isPassed) {
    return Row(
      children: [
        Icon(isPassed ? Icons.check_circle : Icons.warning, color: isPassed ? AppColors.success : AppColors.error, size: 18),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isPassed ? AppColors.textPrimary : AppColors.error)),
      ],
    );
  }
}
