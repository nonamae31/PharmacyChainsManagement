import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../control/stocktake_bloc.dart';
import '../control/stocktake_event.dart';
import '../control/stocktake_state.dart';
import '../entity/stocktake_request_dto.dart';

class StocktakeScreen extends StatefulWidget {
  const StocktakeScreen({super.key});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final _branchController = TextEditingController(text: 'Warehouse 01 (Central Hub)');
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _stocktakeItems = [
    {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 450, 'physicalQty': 450, 'notes': 'Matched (Khớp số liệu)'},
    {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 120, 'physicalQty': 118, 'notes': 'Missing 2 boxes due to tear (Thiếu 2 hộp do rách vỏ)'},
    {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 45, 'physicalQty': 47, 'notes': 'Surplus 2 tubes unrecorded (Dư 2 tuýp chưa nhập sổ)'},
    {'sku': 'SKU-I006', 'name': 'Ibuprofen 400mg Tablets', 'unit': 'boxes', 'bookQty': 15, 'physicalQty': 15, 'notes': 'Matched (Khớp số liệu)'},
  ];

  void _submit() {
    int totalVariance = 0;
    for (var item in _stocktakeItems) {
      totalVariance += ((item['physicalQty'] as int) - (item['bookQty'] as int)).abs();
    }

    final request = StocktakeRequestDto(
      branchId: _branchController.text,
      stocktakeDate: DateTime.now().toIso8601String(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : 'Checked $totalVariance units variance',
      items: const [],
    );
    context.read<StocktakeBloc>().add(StocktakeSubmitted(request));
  }

  @override
  void dispose() {
    _branchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stocktake Management (Kiểm kê kho Thực tế)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<StocktakeBloc, StocktakeState>(
        listener: (context, state) {
          if (state is StocktakeFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is StocktakeSuccess) {
            showAppSuccessDialog(
              context,
              message: '✅ Stocktake audit completed and adjustment report created successfully (Đã hoàn tất kiểm kê và ghi nhận biên bản)!',
              onClose: () => Navigator.of(context).pop(),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
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
                      Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 28),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Physical vs Book Stock Reconciliation Process (Quy trình Kiểm kê Đối soát Thực tế vs Sổ sách)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                            SizedBox(height: 4),
                            Text('Enter physical shelf count. The system automatically calculates variance and logs discrepancy reasons for inventory balancing (Nhập số lượng đếm thực tế, tự động tính độ lệch và cân bằng kho).', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _branchController,
                        decoration: const InputDecoration(labelText: 'Branch / Warehouse Code (Mã chi nhánh / Kho kiểm kê)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Stocktake Notes (Ghi chú đợt kiểm kê tháng 7/2026)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Product Stocktake Sheet (Bảng Kiểm Kê Chi Tiết Sản Phẩm)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildTableHeader('PRODUCT / SKU (SẢN PHẨM)')),
                            Expanded(flex: 2, child: _buildTableHeader('BOOK QTY (SỔ SÁCH)')),
                            Expanded(flex: 2, child: _buildTableHeader('PHYSICAL QTY (THỰC TẾ)')),
                            Expanded(flex: 2, child: _buildTableHeader('VARIANCE (CHÊNH LỆCH)')),
                            Expanded(flex: 3, child: _buildTableHeader('NOTES (GHI CHÚ / THUYẾT MINH)')),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.divider),
                        ..._stocktakeItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final bookQty = item['bookQty'] as int;
                          final physQty = item['physicalQty'] as int;
                          final variance = physQty - bookQty;
                          final isMatch = variance == 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(border: idx == _stocktakeItems.length - 1 ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                                      Text('SKU: ${item['sku']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Expanded(flex: 2, child: Text('$bookQty ${item['unit']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.error),
                                        onPressed: () {
                                          setState(() {
                                            item['physicalQty'] = physQty > 0 ? physQty - 1 : 0;
                                          });
                                        },
                                      ),
                                      Text('$physQty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.success),
                                        onPressed: () {
                                          setState(() {
                                            item['physicalQty'] = physQty + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isMatch ? AppColors.success.withOpacity(0.1) : (variance < 0 ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isMatch ? 'Matched (Khớp 0)' : (variance > 0 ? '+$variance ${item['unit']}' : '$variance ${item['unit']}'),
                                      style: TextStyle(
                                        color: isMatch ? AppColors.success : (variance < 0 ? AppColors.error : const Color(0xFFD97706)),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(item['notes'], style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      child: const Text('Cancel / Back (Hủy / Quay lại)'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: state is StocktakeLoading ? null : _submit,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(state is StocktakeLoading ? 'Submitting (Đang gửi)...' : 'Confirm & Log Stocktake (Xác nhận & Ghi nhận Kiểm kê)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5));
  }
}
