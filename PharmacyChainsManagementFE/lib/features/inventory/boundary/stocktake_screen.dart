import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../control/stocktake_bloc.dart';
import '../control/stocktake_event.dart';
import '../control/stocktake_state.dart';
import '../entity/stocktake_request_dto.dart';

class StocktakeScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  const StocktakeScreen({super.key, this.onBackToDashboard});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final _branchController = TextEditingController(text: 'Warehouse 01 (Central Hub)');
  final _notesController = TextEditingController(text: 'Cycle Count July 2026 - Zone A High Velocity');
  bool _isBlindCount = false;
  String _countMode = 'Cycle Count (Zone A - Fast Moving)';

  final List<Map<String, dynamic>> _stocktakeItems = [
    {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 450, 'physicalQty': 450, 'wmsBin': 'Zone A - Rack 01 - Bin A', 'notes': 'Matched (Khớp số liệu)'},
    {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 120, 'physicalQty': 118, 'wmsBin': 'Zone A - Rack 02 - Bin C', 'notes': 'Missing 2 boxes due to tear (Thiếu 2 hộp do rách vỏ)'},
    {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 45, 'physicalQty': 47, 'wmsBin': 'Zone A - Rack 03 - Bin B', 'notes': 'Surplus 2 tubes unrecorded (Dư 2 tuýp chưa nhập sổ)'},
    {'sku': 'SKU-I006', 'name': 'Ibuprofen 400mg Tablets', 'unit': 'boxes', 'bookQty': 15, 'physicalQty': 15, 'wmsBin': 'Zone A - Rack 01 - Bin D', 'notes': 'Matched (Khớp số liệu)'},
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
        title: const Text('Stocktake Management (Kiểm kê kho Thực tế & Blind Count)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
              message: '✅ Stocktake audit completed! Multi-level approval triggered: Counter Verified ➔ Supervisor Approval ➔ Inventory Manager Sign-off.',
              onClose: () {
                Navigator.of(context).pop();
                if (widget.onBackToDashboard != null) {
                  widget.onBackToDashboard!();
                }
              },
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
                  child: Row(
                    children: [
                      const Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 28),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enterprise WMS Cycle Counting & Blind Reconciliation Process', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                            SizedBox(height: 4),
                            Text('Blind Count mode conceals book quantities to ensure unbiased physical shelf counts. Multi-level approval sign-off required for inventory adjustment.', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF93C5FD))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🙈 Blind Count Mode (Che số sổ sách): ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _isBlindCount ? const Color(0xFFD97706) : AppColors.textSecondary)),
                            Switch(
                              value: _isBlindCount,
                              activeColor: const Color(0xFFD97706),
                              onChanged: (val) {
                                setState(() {
                                  _isBlindCount = val;
                                });
                              },
                            ),
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
                      child: DropdownButtonFormField<String>(
                        value: _countMode,
                        decoration: const InputDecoration(labelText: 'Stocktake Scope (Phạm vi kiểm kê)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'Cycle Count (Zone A - Fast Moving)', child: Text('Cycle Count (Zone A - Fast Moving)')),
                          DropdownMenuItem(value: 'Cycle Count (Zone B - Moderate)', child: Text('Cycle Count (Zone B - Moderate)')),
                          DropdownMenuItem(value: 'Cold Chain Quarantine Zone Check', child: Text('Cold Chain Quarantine Zone Check')),
                          DropdownMenuItem(value: 'Full Annual Warehouse Stocktake', child: Text('Full Annual Warehouse Stocktake')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _countMode = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _branchController,
                        decoration: const InputDecoration(labelText: 'Branch / Warehouse Code (Mã chi nhánh / Kho)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Stocktake Notes & Audit Reference', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Product Stocktake Sheet (Bảng Kiểm Kê Chi Tiết Sản Phẩm)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFDE68A))),
                      child: const Text('📋 Multi-Level Sign-off: Step 1 Counter Count (In Progress)', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
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
                            Expanded(flex: 3, child: _buildTableHeader('PRODUCT / SKU (SẢN PHẨM & VỊ TRÍ)')),
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
                                      const SizedBox(height: 2),
                                      Text('${item['sku']} • 📍 ${item['wmsBin']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _isBlindCount
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('[🙈 HIDDEN BLIND]', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                        )
                                      : Text('$bookQty ${item['unit']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                ),
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
                                  child: _isBlindCount
                                      ? const Text('Auto-calculating on submit', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)))
                                      : Container(
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
                      onPressed: () {
                        if (widget.onBackToDashboard != null) {
                          widget.onBackToDashboard!();
                        } else if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bạn đang ở màn hình Kiểm kê kho. Sử dụng menu bên trái để chuyển đổi chức năng khác.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                      child: const Text('Cancel / Back (Hủy / Quay lại)'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: state is StocktakeLoading ? null : _submit,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: Text(state is StocktakeLoading ? 'Submitting (Đang gửi)...' : 'Confirm & Log Stocktake (Submit to Supervisor & Manager)'),
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
