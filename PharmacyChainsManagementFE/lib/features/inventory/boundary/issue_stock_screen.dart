import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/primary_button.dart';
import '../control/issue_stock_bloc.dart';
import '../control/issue_stock_event.dart';
import '../control/issue_stock_state.dart';
import '../entity/issue_stock_request_dto.dart';

class _IssueItemModel {
  String medicineId;
  String medicineName;
  String batchNo;
  String expiryDate;
  int requestedQty;
  int pickedQty;
  String unit;
  String wmsPickingBin;
  bool isSealedAndVerified;

  _IssueItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.batchNo,
    required this.expiryDate,
    required this.requestedQty,
    required this.pickedQty,
    required this.unit,
    required this.wmsPickingBin,
    this.isSealedAndVerified = true,
  });
}

class IssueStockScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  const IssueStockScreen({super.key, this.onBackToDashboard});

  @override
  State<IssueStockScreen> createState() => _IssueStockScreenState();
}

class _IssueStockScreenState extends State<IssueStockScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedStore = 'Store 01 (Hoan Kiem Pharmacy Branch)';
  final _requestNoController = TextEditingController(text: 'REQ-VN-2026-088');
  String _priority = 'Sức khỏe khẩn cấp (Urgent Replenishment)';

  final List<_IssueItemModel> _items = [
    _IssueItemModel(
      medicineId: 'SKU-A001',
      medicineName: 'Panadol Extra 500mg (Paracetamol & Caffeine)',
      batchNo: 'LOT-2026-GSK-081',
      expiryDate: '2029-01-15 (FEFO Priority)',
      requestedQty: 120,
      pickedQty: 120,
      unit: 'Boxes',
      wmsPickingBin: 'Zone A - Rack 04 - Bin B',
      isSealedAndVerified: true,
    ),
    _IssueItemModel(
      medicineId: 'SKU-V003',
      medicineName: 'Vitamin C Sủi 1000mg (Sanofi)',
      batchNo: 'LOT-2023-VC09',
      expiryDate: '2026-07-20 (Near Expiry - Strict FEFO)',
      requestedQty: 45,
      pickedQty: 45,
      unit: 'Tubes',
      wmsPickingBin: 'Quarantine / Zone C - Shelf 02',
      isSealedAndVerified: true,
    ),
  ];

  void _addItemDialog() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController(text: 'SKU-NEW0${_items.length + 1}');
    final batchCtrl = TextEditingController(text: 'LOT-2026-FEFO-${10 + _items.length}');
    final expCtrl = TextEditingController(text: '2028-05-15 (FEFO Selected)');
    final reqQtyCtrl = TextEditingController(text: '60');
    final pickQtyCtrl = TextEditingController(text: '60');
    final unitCtrl = TextEditingController(text: 'Boxes');
    final binCtrl = TextEditingController(text: 'Zone A - Rack 01 - Bin A');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add SKU to Pick List (Thêm Sản Phẩm Xuất Kho)', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name (Tên thuốc) *', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU / Medicine ID *', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (Đơn vị)', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch Number (Số Lô FEFO) *', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'Expiry Date', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: reqQtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Requested Qty', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: pickQtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Picked Qty (Nhặt thực tế)', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: binCtrl, decoration: const InputDecoration(labelText: 'WMS Picking Bin (Vị trí nhặt hàng)', border: OutlineInputBorder(), isDense: true)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton.icon(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || skuCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Vui lòng nhập tên và mã SKU!')));
                return;
              }
              setState(() {
                _items.add(_IssueItemModel(
                  medicineId: skuCtrl.text.trim(),
                  medicineName: nameCtrl.text.trim(),
                  batchNo: batchCtrl.text.trim(),
                  expiryDate: expCtrl.text.trim(),
                  requestedQty: int.tryParse(reqQtyCtrl.text) ?? 60,
                  pickedQty: int.tryParse(pickQtyCtrl.text) ?? 60,
                  unit: unitCtrl.text.trim(),
                  wmsPickingBin: binCtrl.text.trim(),
                ));
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã thêm "${nameCtrl.text.trim()}" theo đúng khuyến nghị FEFO!'), behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm Vào Danh Sách Nhặt'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _editPickQty(_IssueItemModel item) {
    final qtyCtrl = TextEditingController(text: item.pickedQty.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Điều chỉnh số lượng nhặt - ${item.medicineId}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Text('Yêu cầu từ chi nhánh: ${item.requestedQty} ${item.unit}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số lượng thực tế nhặt kho (Picked Qty)', border: OutlineInputBorder(), isDense: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.pickedQty = int.tryParse(qtyCtrl.text) ?? item.pickedQty;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã cập nhật số lượng nhặt cho ${item.medicineId}!'), behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Cập Nhật Nhặt Hàng'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Vui lòng thêm ít nhất 1 sản phẩm xuất kho!'), backgroundColor: AppColors.error));
        return;
      }

      final dtos = _items.map((e) => IssueStockItemDto(
        medicineId: e.medicineId,
        quantity: e.pickedQty,
      )).toList();

      final request = IssueStockRequestDto(
        storeId: _selectedStore,
        requestNo: _requestNoController.text.trim(),
        items: dtos,
      );

      context.read<IssueStockBloc>().add(IssueStockSubmitted(request));
    }
  }

  @override
  void dispose() {
    _requestNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Outbound Picking & Branch Dispatch (Quản Lý Xuất Kho & Cung Ứng)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<IssueStockBloc, IssueStockState>(
        listener: (context, state) {
          if (state is IssueStockFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is IssueStockSuccess) {
            showAppSuccessDialog(
              context,
              message: '🚚 Đã xuất kho và gửi hàng thành công cho chi nhánh $_selectedStore theo đúng nguyên tắc FEFO! Phiếu xuất kho #${_requestNoController.text} đã được niêm phong.',
              onClose: () {
                if (widget.onBackToDashboard != null) {
                  widget.onBackToDashboard!();
                } else if (Navigator.of(context).canPop() && ModalRoute.of(context)?.isFirst == false) {
                  Navigator.of(context).pop();
                }
              },
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEFO info banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.outbox, color: Color(0xFFB45309), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FEFO Outbound Picking Allocation (Tuân thủ xuất hàng theo hạn dùng FEFO)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF92400E))),
                              const SizedBox(height: 4),
                              Text('Hệ thống tự động phân bổ lô hàng cận date trước (First-Expired, First-Out) để tối ưu chu kỳ tồn kho và chống hết hạn tại tổng kho.', style: TextStyle(fontSize: 13, color: const Color(0xFF92400E).withValues(alpha: 0.95))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Store & Request Details Form
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Thông Tin Yêu Cầu Cung Ứng (Branch Replenishment Request)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 650) {
                                return Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedStore,
                                      decoration: const InputDecoration(labelText: 'Chi Nhánh Đích (Target Store / Branch) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.store)),
                                      items: const [
                                        DropdownMenuItem(value: 'Store 01 (Hoan Kiem Pharmacy Branch)', child: Text('Store 01 (Hoan Kiem Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 02 (Cau Giay Pharmacy Branch)', child: Text('Store 02 (Cau Giay Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 03 (Hai Ba Trung Central Store)', child: Text('Store 03 (Hai Ba Trung Central Store)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 04 (Ba Dinh Pharmacy Branch)', child: Text('Store 04 (Ba Dinh Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedStore = val);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(controller: _requestNoController, decoration: const InputDecoration(labelText: 'Mã Phiếu Yêu Cầu (Request No.) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.numbers))),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      initialValue: _priority,
                                      decoration: const InputDecoration(labelText: 'Mức Độ Ưu Tiên (Priority)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.priority_high, color: AppColors.error)),
                                      items: const [
                                        DropdownMenuItem(value: 'Sức khỏe khẩn cấp (Urgent Replenishment)', child: Text('Sức khỏe khẩn cấp (Urgent Replenishment)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Định kỳ hằng tuần (Regular Weekly Restock)', child: Text('Định kỳ hằng tuần (Regular Weekly Restock)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Đơn bổ sung đột xuất (Ad-hoc Restock)', child: Text('Đơn bổ sung đột xuất (Ad-hoc Restock)', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _priority = val);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedStore,
                                      decoration: const InputDecoration(labelText: 'Chi Nhánh Đích (Target Store / Branch) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.store)),
                                      items: const [
                                        DropdownMenuItem(value: 'Store 01 (Hoan Kiem Pharmacy Branch)', child: Text('Store 01 (Hoan Kiem Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 02 (Cau Giay Pharmacy Branch)', child: Text('Store 02 (Cau Giay Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 03 (Hai Ba Trung Central Store)', child: Text('Store 03 (Hai Ba Trung Central Store)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Store 04 (Ba Dinh Pharmacy Branch)', child: Text('Store 04 (Ba Dinh Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedStore = val);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: TextField(controller: _requestNoController, decoration: const InputDecoration(labelText: 'Mã Phiếu Yêu Cầu (Request No.) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.numbers)))),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _priority,
                                      decoration: const InputDecoration(labelText: 'Mức Độ Ưu Tiên (Priority)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.priority_high, color: AppColors.error)),
                                      items: const [
                                        DropdownMenuItem(value: 'Sức khỏe khẩn cấp (Urgent Replenishment)', child: Text('Sức khỏe khẩn cấp (Urgent Replenishment)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Định kỳ hằng tuần (Regular Weekly Restock)', child: Text('Định kỳ hằng tuần (Regular Weekly Restock)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Đơn bổ sung đột xuất (Ad-hoc Restock)', child: Text('Đơn bổ sung đột xuất (Ad-hoc Restock)', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _priority = val);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Picking list header & Add button
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      const Text('2. Danh Sách Nhặt Hàng Theo Khuyến Nghị FEFO (WMS Picking List)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ElevatedButton.icon(
                        onPressed: _addItemDialog,
                        icon: const Icon(Icons.add_box, size: 18),
                        label: const Text('+ Thêm Mã Thuốc Vào Phiếu Nhặt'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Items Card Table
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _items.isEmpty
                          ? Container(
                              height: 160,
                              alignment: Alignment.center,
                              child: const Text('⚠️ Chưa có sản phẩm nào trong danh sách nhặt. Vui lòng bấm "+ Thêm Mã Thuốc" ở trên!', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : LayoutBuilder(
                              builder: (context, cardConstraints) {
                                final isNarrow = cardConstraints.maxWidth < 800;
                                if (isNarrow) {
                                  return Column(
                                    children: _items.map((item) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text('${item.medicineName} (${item.medicineId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => setState(() => _items.remove(item))),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text('Lot FEFO: ${item.batchNo} • Expiry: ${item.expiryDate}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                            Text('Bin: ${item.wmsPickingBin}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                            Wrap(
                                              alignment: WrapAlignment.spaceBetween,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                Flexible(child: Text('Yêu cầu: ${item.requestedQty} → Nhặt: ${item.pickedQty} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)))),
                                                ElevatedButton.icon(onPressed: () => _editPickQty(item), icon: const Icon(Icons.edit, size: 16), label: const Text('Sửa nhặt')),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }

                                final tableWidth = cardConstraints.maxWidth > 950 ? cardConstraints.maxWidth : 950.0;
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: tableWidth),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                          child: const Row(
                                            children: [
                                              SizedBox(width: 250, child: Text('PRODUCT / SKU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 140, child: Text('BATCH FEFO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 150, child: Text('EXPIRY PRIORITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 130, child: Text('REQ / PICK QTY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 170, child: Text('PICKING BIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 110, child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.right)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._items.map((item) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 250,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      Text(item.medicineId, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 140, child: Text(item.batchNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB45309)))),
                                                SizedBox(width: 150, child: Text(item.expiryDate, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis)),
                                                SizedBox(
                                                  width: 130,
                                                  child: Text(
                                                    '${item.pickedQty} / ${item.requestedQty} ${item.unit}',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: item.pickedQty == item.requestedQty ? const Color(0xFF10B981) : const Color(0xFFD97706)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 170,
                                                  child: Text(item.wmsPickingBin, style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                                                ),
                                                SizedBox(
                                                  width: 110,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                                        tooltip: 'Sửa số lượng nhặt',
                                                        onPressed: () => _editPickQty(item),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                                        tooltip: 'Xóa',
                                                        onPressed: () => setState(() => _items.remove(item)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onBackToDashboard != null) ...[
                        OutlinedButton(
                          onPressed: widget.onBackToDashboard,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                          child: const Text('Trở lại Dashboard'),
                        ),
                        const SizedBox(width: 16),
                      ],
                      PrimaryButton(
                        text: '🚚 Niêm Phong Kiện Hàng & Xuất Kho Cung Ứng (Dispatch)',
                        isLoading: state is IssueStockLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
