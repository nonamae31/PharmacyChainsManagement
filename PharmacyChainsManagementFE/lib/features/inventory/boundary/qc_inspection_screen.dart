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
      'qcStage': 'Step 4: Lab Testing & Assay Check',
      'retainedSample': 10,
      'coaFile': 'COA_GSK_LOT_081_Signed.pdf',
      'signedBy': 'e-Signed by QC Lead Pharmacist',
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
      'qcStage': 'Step 1: Visual Inspection (Failed)',
      'retainedSample': 5,
      'coaFile': 'COA_PFI_LOT_112.pdf',
      'signedBy': 'Pending e-Signature',
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
      'qcStage': 'Step 5: Released to Putaway',
      'retainedSample': 8,
      'coaFile': 'COA_SFO_LOT_045_Verified.pdf',
      'signedBy': 'e-Signed by QC Inspector Trần Mai',
      'inspectorNote': 'Meets GSP standards. COA Lot matched lab specification.',
    },
  ];

  void _updateStatus(int index, String newStatus) {
    if (newStatus.contains('Rejected')) {
      _showRejectDialog(context, index);
      return;
    }
    setState(() {
      _qcBatches[index]['status'] = newStatus;
      if (newStatus.contains('Passed')) {
        _qcBatches[index]['qcStage'] = 'Step 5: Released to Putaway';
        _qcBatches[index]['signedBy'] = 'e-Signed by Pharmacist on Duty';
      } else {
        _qcBatches[index]['qcStage'] = 'Quarantined / Return Process';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật kết quả QC lô ${_qcBatches[index]['batchNo']} thành: $newStatus'),
        backgroundColor: newStatus.contains('Passed') ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int index) {
    final batchNo = _qcBatches[index]['batchNo'];
    final medicineName = _qcBatches[index]['medicineName'];
    final reasonController = TextEditingController();
    String selectedReason = 'Bao bì rách, móp méo hoặc ngấm nước (Damaged/Wet outer packaging)';
    final predefinedReasons = [
      'Bao bì rách, móp méo hoặc ngấm nước (Damaged/Wet outer packaging)',
      'Vi phạm nhiệt độ bảo quản trong quá trình vận chuyển (Cold chain temperature breach)',
      'Không đạt kiểm định COA / Phiếu kiểm nghiệm không hợp lệ (Invalid or missing COA)',
      'Hạn sử dụng dưới 6 tháng hoặc cận date (Near-expiry stock < 6 months)',
      'Số lượng thực tế sai lệch lớn so với PO (Quantity discrepancy / Wrong SKU)',
      'Lý do khác (Khác - Vui lòng ghi chi tiết bên dưới)',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                const SizedBox(width: 10),
                const Expanded(child: Text('Ghi nhận Lý do Từ chối & Hoàn trả Lô QC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error))),
              ],
            ),
            content: SizedBox(
              width: 550,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lô hàng: $batchNo', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                          Text('Sản phẩm: $medicineName', style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Chọn lý do từ chối chuẩn GSP (*bắt buộc):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...predefinedReasons.map((r) => RadioListTile<String>(
                      title: Text(r, style: const TextStyle(fontSize: 13)),
                      value: r,
                      groupValue: selectedReason,
                      activeColor: AppColors.error,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        if (val != null) setStateDialog(() => selectedReason = val);
                      },
                    )),
                    const SizedBox(height: 12),
                    const Text('Ghi chú chi tiết & Hướng dẫn hoàn trả cho NCC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nhập mô tả cụ thể về tình trạng lỗi, hình thức chụp ảnh xác nhận hoặc biên bản trả hàng...',
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy bỏ'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final customNote = reasonController.text.trim();
                  if (selectedReason.contains('Lý do khác') && customNote.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('⚠️ Vui lòng nhập chi tiết lý do từ chối vào ô Ghi chú chi tiết!'), backgroundColor: AppColors.warning),
                    );
                    return;
                  }
                  final fullReason = customNote.isNotEmpty ? '$selectedReason - $customNote' : selectedReason;
                  
                  setState(() {
                    _qcBatches[index]['status'] = 'Rejected - Return to Supplier';
                    _qcBatches[index]['qcStage'] = 'Quarantined / Return Process';
                    _qcBatches[index]['signedBy'] = 'Rejected & Signed by QC Inspector';
                    _qcBatches[index]['inspectorNote'] = '❌ LÝ DO TỪ CHỐI: $fullReason';
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Đã từ chối lô $batchNo và lập biên bản hoàn trả NCC. Lý do: $fullReason'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Xác nhận Từ chối & Hoàn trả'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCoaViewer(String fileName, String batchNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
            const SizedBox(width: 10),
            Text('COA Attachment: $fileName'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Certificate of Analysis (COA) for Batch $batchNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Assay Content: 99.8% (Target: 95.0 - 105.0%)\n• Dissolution Rate: Passed in 15 mins\n• Impurities Test: < 0.05% (GSP Compliant)\n• Microbiological Limit Check: Sterile / Passed', style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('📎 PDF document digitally verified against supplier lab hash.', style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close COA Viewer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QC Inspection (Kiểm tra chất lượng GSP/GDP & Lưu mẫu)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-Step QC Workflow Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fact_check, color: AppColors.primary, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enterprise Multi-Step QC Inspection Workflow (Quy trình Kiểm định GSP 5 bước)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                            SizedBox(height: 4),
                            Text('1. Visual Inspection ➔ 2. Temperature Check (2-8°C / 15-25°C) ➔ 3. Document Check (COA) ➔ 4. Lab Testing & Retention ➔ 5. Release to Putaway', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
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
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(4)),
                                child: Text(item['qcStage'], style: const TextStyle(color: Color(0xFF6B21A8), fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          Text('PO: ${item['poNo']} • Received Date: ${item['receivedDate']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item['medicineName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Supplier (Nhà cung cấp): ${item['supplier']}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          Row(
                            children: [
                              Text('🧪 Sample Retention (Lưu mẫu): ${item['retainedSample']} boxes', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 13)),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: () => _showCoaViewer(item['coaFile'], item['batchNo']),
                                icon: const Icon(Icons.picture_as_pdf, size: 16, color: Color(0xFFEF4444)),
                                label: Text('COA: ${item['coaFile']}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      Row(
                        children: [
                          _buildCheckItem('GSP Temperature Compliance (Nhiệt độ bảo quản GSP)', item['tempCompliance']),
                          const SizedBox(width: 24),
                          _buildCheckItem('Intact Packaging (Bao bì nguyên vẹn)', item['packagingIntact']),
                          const SizedBox(width: 24),
                          _buildCheckItem('Valid COA Verified (COA hợp lệ)', item['coaVerified']),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Inspector Note: ${item['inspectorNote']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: (item['inspectorNote'] as String).contains('LÝ DO TỪ CHỐI:') ? FontWeight.bold : FontWeight.normal,
                                color: (item['inspectorNote'] as String).contains('LÝ DO TỪ CHỐI:') ? AppColors.error : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text('✍️ ${item['signedBy']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF059669), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!status.contains('Rejected'))
                            OutlinedButton.icon(
                              onPressed: () => _showRejectDialog(context, idx),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Reject & Return (Từ chối & Hoàn trả)'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            ),
                          const SizedBox(width: 12),
                          if (!status.contains('Passed'))
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus(idx, 'Passed QC - Ready for Storage'),
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Pass QC & Approve (Duyệt đạt chuẩn QC & Ký số)'),
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
