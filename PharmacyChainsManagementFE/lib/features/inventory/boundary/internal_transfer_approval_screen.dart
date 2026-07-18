import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class InternalTransferApprovalScreen extends StatefulWidget {
  const InternalTransferApprovalScreen({super.key});

  @override
  State<InternalTransferApprovalScreen> createState() => _InternalTransferApprovalScreenState();
}

class _InternalTransferApprovalScreenState extends State<InternalTransferApprovalScreen> {
  final List<Map<String, dynamic>> _transfers = [
    {
      'transferId': 'TRF-2026-089',
      'fromBranch': 'Warehouse 01 (FPT Campus Central)',
      'toBranch': 'Store #05 - Cầu Giấy Branch',
      'requestedBy': 'Trần Thị Mai (Store Manager)',
      'requestDate': '2026-07-18 08:30 AM',
      'status': 'Pending Approval',
      'items': [
        {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'qty': 50, 'unit': 'boxes', 'availableStock': 380},
        {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg', 'qty': 20, 'unit': 'boxes', 'availableStock': 120},
      ],
      'note': 'Bổ sung tồn kho khẩn cấp do đợt dịch cúm gia tăng.',
    },
    {
      'transferId': 'TRF-2026-088',
      'fromBranch': 'Warehouse 01 (FPT Campus Central)',
      'toBranch': 'Store #02 - Hoàn Kiếm Branch',
      'requestedBy': 'Lê Văn Hùng (Pharmacist)',
      'requestDate': '2026-07-17 03:15 PM',
      'status': 'Approved - In Transit',
      'items': [
        {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'qty': 100, 'unit': 'tubes', 'availableStock': 8},
      ],
      'note': 'Chuyển hàng định kỳ tuần 3 tháng 7.',
    },
  ];

  void _processTransfer(int index, String action) {
    setState(() {
      _transfers[index]['status'] = action == 'Approve' ? 'Approved - Ready for Dispatch' : 'Rejected by Manager';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action == 'Approve'
            ? '✅ Đã duyệt phiếu điều chuyển ${_transfers[index]['transferId']}! Hàng sẵn sàng xuất kho.'
            : '❌ Đã từ chối phiếu điều chuyển ${_transfers[index]['transferId']}.'),
        backgroundColor: action == 'Approve' ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Internal Transfer Approval (Duyệt điều chuyển kho)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.swap_horiz, color: Color(0xFFD97706), size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inter-Branch Stock Transfer Management (Quản lý Điều chuyển Hàng giữa các Chi nhánh)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF92400E))),
                        SizedBox(height: 4),
                        Text('Verify available warehouse stock before approving transfer requests from member store branches (Kiểm tra số lượng tồn khả dụng trước khi phê duyệt phiếu chuyển từ chi nhánh).', style: TextStyle(fontSize: 13, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Transfer Request Queue (Phiếu yêu cầu điều chuyển)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            ..._transfers.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final status = item['status'] as String;
              Color statusColor = AppColors.warning;
              if (status.contains('Approved')) statusColor = AppColors.success;
              if (status.contains('Rejected')) statusColor = AppColors.error;

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
                              Text(item['transferId'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                            ],
                          ),
                          Text('Request Date (Ngày yêu cầu): ${item['requestDate']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.storefront, color: AppColors.info, size: 20),
                          const SizedBox(width: 8),
                          Text('From (Từ): ${item['fromBranch']}  ➔  To (Đến): ${item['toBranch']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Requested By (Người yêu cầu): ${item['requestedBy']} • Note (Ghi chú): ${item['note']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const Divider(height: 24, color: AppColors.divider),
                      const Text('Transfer Items Detail (Chi tiết hàng hóa điều chuyển):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ...(item['items'] as List<Map<String, dynamic>>).map((subItem) {
                        final available = subItem['availableStock'] as int;
                        final requested = subItem['qty'] as int;
                        final enoughStock = available >= requested;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${subItem['name']} (${subItem['sku']})', style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  Text('Requested (Yêu cầu): $requested ${subItem['unit']}  |  Available Stock (Tồn kho): $available ${subItem['unit']}',
                                      style: TextStyle(color: enoughStock ? AppColors.textPrimary : AppColors.error, fontWeight: enoughStock ? FontWeight.normal : FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Icon(enoughStock ? Icons.check_circle : Icons.error, color: enoughStock ? AppColors.success : AppColors.error, size: 16),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      if (status == 'Pending Approval')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _processTransfer(idx, 'Reject'),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject Request (Từ chối phiếu)'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _processTransfer(idx, 'Approve'),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve Transfer (Phê duyệt điều chuyển)'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
