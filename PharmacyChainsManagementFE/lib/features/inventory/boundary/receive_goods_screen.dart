import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/primary_button.dart';
import '../control/receive_goods_bloc.dart';
import '../control/receive_goods_event.dart';
import '../control/receive_goods_state.dart';
import '../entity/receive_goods_request_dto.dart';
import 'widgets/verification_photos_modal.dart';

class _ReceiveItemModel {
  String medicineId;
  String medicineName;
  String batchNo;
  String expiryDate;
  int quantity;
  String unit;
  String wmsLocation;
  String? proofImage;
  Map<String, String>? verificationPhotos;

  _ReceiveItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.batchNo,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.wmsLocation,
    this.proofImage,
    this.verificationPhotos,
  });
}

class ReceiveGoodsScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  const ReceiveGoodsScreen({super.key, this.onBackToDashboard});

  @override
  State<ReceiveGoodsScreen> createState() => _ReceiveGoodsScreenState();
}

class _ReceiveGoodsScreenState extends State<ReceiveGoodsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSupplier = 'GSK Vietnam (GlaxoSmithKline)';
  final _poController = TextEditingController(text: 'PO-20260718-01');
  final _deliveryNoteController = TextEditingController(text: 'DN-GSK-88902');

  final List<_ReceiveItemModel> _items = [
    _ReceiveItemModel(
      medicineId: 'SKU-A001',
      medicineName: 'Panadol Extra 500mg (Paracetamol & Caffeine)',
      batchNo: 'LOT-2026-GSK-081',
      expiryDate: '2029-01-15',
      quantity: 500,
      unit: 'Boxes',
      wmsLocation: 'Zone A - Rack 04 - Bin B',
      proofImage: 'COA_GSK_081_Verified.pdf',
    ),
    _ReceiveItemModel(
      medicineId: 'SKU-B002',
      medicineName: 'Amoxicillin 500mg Capsules (Broad-spectrum)',
      batchNo: 'LOT-2026-GSK-112',
      expiryDate: '2028-06-10',
      quantity: 300,
      unit: 'Boxes',
      wmsLocation: 'Zone B - Rack 01 - Bin C',
    ),
  ];

  void _addItemDialog() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController(text: 'SKU-NEW0${_items.length + 1}');
    final batchCtrl = TextEditingController(text: 'LOT-2026-GSK-${100 + _items.length}');
    final expCtrl = TextEditingController(text: '2029-07-20');
    final qtyCtrl = TextEditingController(text: '200');
    final unitCtrl = TextEditingController(text: 'Boxes');
    final locCtrl = TextEditingController(text: 'Zone A - Rack 02 - Bin A');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Inbound Item (Thêm Sản Phẩm Nhập Kho)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Expanded(child: TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch Number (Số Lô) *', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (Số lượng) *', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'WMS Location (Vị trí cất)', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton.icon(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || skuCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ tên thuốc và mã SKU!')));
                return;
              }
              setState(() {
                _items.add(_ReceiveItemModel(
                  medicineId: skuCtrl.text.trim(),
                  medicineName: nameCtrl.text.trim(),
                  batchNo: batchCtrl.text.trim(),
                  expiryDate: expCtrl.text.trim().isNotEmpty ? expCtrl.text.trim() : '2029-01-01',
                  quantity: int.tryParse(qtyCtrl.text) ?? 100,
                  unit: unitCtrl.text.trim(),
                  wmsLocation: locCtrl.text.trim(),
                ));
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã thêm "${nameCtrl.text.trim()}" vào danh sách nhập!'), behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm vào Phiếu Nhập'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _editItem(_ReceiveItemModel item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final batchCtrl = TextEditingController(text: item.batchNo);
    final locCtrl = TextEditingController(text: item.wmsLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Điều chỉnh sản phẩm - ${item.medicineId}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 14),
              TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng thực tế nhập kho', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Số lô (Batch Number)', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Vị trí WMS (Putaway Location)', border: OutlineInputBorder(), isDense: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.quantity = int.tryParse(qtyCtrl.text) ?? item.quantity;
                item.batchNo = batchCtrl.text.trim();
                item.wmsLocation = locCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã cập nhật ${item.medicineId}!'), behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Lưu Thay Đổi'),
          ),
        ],
      ),
    );
  }

  void _attachProof(_ReceiveItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => VerificationPhotosModal(
        medicineTitle: '${item.medicineName} (${item.medicineId})',
        initialPhotos: item.verificationPhotos != null ? Map<String, dynamic>.from(item.verificationPhotos!) : null,
        onSubmitted: (photos) {
          setState(() {
            item.verificationPhotos = photos;
            item.proofImage = 'Đã gửi đủ 3 ảnh (Front, Back, Label)';
          });
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Vui lòng thêm ít nhất 1 sản phẩm vào Phiếu Nhập!'), backgroundColor: AppColors.error));
        return;
      }

      final dtos = _items.map((e) => ReceiveGoodsItemDto(
        medicineId: e.medicineId,
        batchNo: e.batchNo,
        expiryDate: e.expiryDate,
        quantity: e.quantity,
      )).toList();

      final request = ReceiveGoodsRequestDto(
        supplierId: _selectedSupplier,
        poId: _poController.text.trim().isNotEmpty ? _poController.text.trim() : null,
        deliveryNoteNo: _deliveryNoteController.text.trim().isNotEmpty ? _deliveryNoteController.text.trim() : null,
        receivedDate: DateTime.now().toIso8601String(),
        items: dtos,
      );

      context.read<ReceiveGoodsBloc>().add(ReceiveGoodsSubmitted(request));
    }
  }

  @override
  void dispose() {
    _poController.dispose();
    _deliveryNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WMS Receive Goods & Putaway (Quản Lý Nhập Kho & Vị Trí Cất)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<ReceiveGoodsBloc, ReceiveGoodsState>(
        listener: (context, state) {
          if (state is ReceiveGoodsFailure) {
            showAppErrorDialog(context, message: state.message);
          } else if (state is ReceiveGoodsSuccess) {
            showAppSuccessDialog(
              context,
              message: '✅ Đã nhập kho thành công ${_items.length} mã SKU từ nhà cung cấp $_selectedSupplier! Toàn bộ số lượng đã được cộng vào kho và gán vị trí WMS.',
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
                  // ASN info banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, color: AppColors.primary, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Advance Shipping Notice (ASN) & Inbound Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                              const SizedBox(height: 4),
                              Text('Kiểm tra đối chiếu số lượng thực tế với Đơn đặt hàng (PO) và Phiếu giao hàng (Delivery Note). Hệ thống tự động gợi ý vị trí kệ cất (WMS Putaway).', style: TextStyle(fontSize: 13, color: AppColors.primaryDark.withValues(alpha: 0.95))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Supplier & PO Form
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Thông Tin Nhập Lô Hàng (Inbound Shipment Details)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 650) {
                                return Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedSupplier,
                                      decoration: const InputDecoration(labelText: 'Nhà cung cấp (Supplier) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.business)),
                                      items: const [
                                        DropdownMenuItem(value: 'GSK Vietnam (GlaxoSmithKline)', child: Text('GSK Vietnam (GlaxoSmithKline)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Pfizer Pharma Vietnam', child: Text('Pfizer Pharma Vietnam', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'AstraZeneca Vietnam Co.', child: Text('AstraZeneca Vietnam Co.', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Sanofi Aventis Vietnam', child: Text('Sanofi Aventis Vietnam', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedSupplier = val);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(controller: _poController, decoration: const InputDecoration(labelText: 'Mã Đơn Đặt Hàng (PO ID)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.receipt_long))),
                                    const SizedBox(height: 12),
                                    TextField(controller: _deliveryNoteController, decoration: const InputDecoration(labelText: 'Phiếu Giao Hàng (Delivery Note No)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.description_outlined))),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedSupplier,
                                      decoration: const InputDecoration(labelText: 'Nhà cung cấp (Supplier) *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.business)),
                                      items: const [
                                        DropdownMenuItem(value: 'GSK Vietnam (GlaxoSmithKline)', child: Text('GSK Vietnam (GlaxoSmithKline)', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Pfizer Pharma Vietnam', child: Text('Pfizer Pharma Vietnam', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'AstraZeneca Vietnam Co.', child: Text('AstraZeneca Vietnam Co.', overflow: TextOverflow.ellipsis)),
                                        DropdownMenuItem(value: 'Sanofi Aventis Vietnam', child: Text('Sanofi Aventis Vietnam', overflow: TextOverflow.ellipsis)),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedSupplier = val);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: TextField(controller: _poController, decoration: const InputDecoration(labelText: 'Mã Đơn Đặt Hàng (PO ID)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.receipt_long)))),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 2, child: TextField(controller: _deliveryNoteController, decoration: const InputDecoration(labelText: 'Phiếu Giao Hàng (Delivery Note)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.description_outlined)))),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Items table header with Add button
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      const Text('2. Danh Sách Sản Phẩm Nhập & Vị Trí Cất (Inbound Items & WMS Bin Putaway)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ElevatedButton.icon(
                        onPressed: _addItemDialog,
                        icon: const Icon(Icons.add_box, size: 18),
                        label: const Text('+ Thêm Sản Phẩm Nhập'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Table or cards
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg), side: BorderSide(color: AppColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _items.isEmpty
                          ? Container(
                              height: 160,
                              alignment: Alignment.center,
                              child: const Text('⚠️ Chưa có sản phẩm nào trong phiếu nhập. Vui lòng bấm "+ Thêm Sản Phẩm Nhập" ở trên!', style: TextStyle(color: AppColors.textSecondary)),
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
                                            Text('Batch: ${item.batchNo} • Expiry: ${item.expiryDate}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                            Text('Qty: ${item.quantity} ${item.unit} • WMS Bin: ${item.wmsLocation}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              alignment: WrapAlignment.end,
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                OutlinedButton.icon(onPressed: () => _attachProof(item), icon: const Icon(Icons.photo_library, size: 16), label: Text(item.proofImage != null ? '🖼️ Đã gửi 3 ảnh' : '🖼️ Gửi ảnh xác minh (3 ảnh)')),
                                                ElevatedButton.icon(onPressed: () => _editItem(item), icon: const Icon(Icons.edit, size: 16), label: const Text('Sửa')),
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
                                              SizedBox(width: 140, child: Text('BATCH NUMBER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 120, child: Text('EXPIRY DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 110, child: Text('QUANTITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 180, child: Text('WMS BIN PUTAWAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                              SizedBox(width: 150, child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.right)),
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
                                                SizedBox(width: 140, child: Text(item.batchNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                                SizedBox(width: 120, child: Text(item.expiryDate, style: const TextStyle(fontSize: 13))),
                                                SizedBox(width: 110, child: Text('${item.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)))),
                                                SizedBox(
                                                  width: 180,
                                                  child: Text(item.wmsLocation, style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(item.proofImage != null ? Icons.verified : Icons.photo_library_outlined, color: item.proofImage != null ? AppColors.success : AppColors.primary, size: 20),
                                                        tooltip: item.proofImage != null ? 'Minh chứng: ${item.proofImage}' : 'Đính kèm ảnh từ thư viện',
                                                        onPressed: () => _attachProof(item),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                                                        tooltip: 'Sửa số liệu',
                                                        onPressed: () => _editItem(item),
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
                        text: '📦 Xác Nhận Nhập Kho & Gán Vị Trí WMS (Putaway)',
                        isLoading: state is ReceiveGoodsLoading,
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
