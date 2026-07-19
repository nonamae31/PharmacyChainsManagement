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
  String _selectedBranch = 'Store 01 (Hoan Kiem Pharmacy Branch)';
  final _notesController = TextEditingController(text: 'Audit: Cycle Count (Zone A - Fast Moving) • Store 01 (Hoan Kiem Pharmacy Branch)');
  bool _isBlindCount = false;
  String _countMode = 'Cycle Count (Zone A - Fast Moving)';
  bool _isLoadingList = false;

  late List<Map<String, dynamic>> _stocktakeItems;

  @override
  void initState() {
    super.initState();
    _stocktakeItems = _getScopeItems(_countMode, _selectedBranch);
  }

  List<Map<String, dynamic>> _getScopeItems(String scope, String branch) {
    // 1. Store 01 (Hoan Kiem Pharmacy Branch)
    if (branch.contains('Store 01')) {
      final zoneA = [
        {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 45, 'physicalQty': 45, 'wmsBin': 'Store01 - Shelf A1 - Bin 01', 'notes': 'Khớp số liệu quầy (Matched)'},
        {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 18, 'physicalQty': 17, 'wmsBin': 'Store01 - Shelf A2 - Bin 03', 'notes': 'Thiếu 1 hộp do khách đang thử hàng'},
        {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 30, 'physicalQty': 32, 'wmsBin': 'Store01 - Shelf A3 - Bin 02', 'notes': 'Dư 2 tuýp từ đợt KM trước'},
        {'sku': 'SKU-I006', 'name': 'Ibuprofen 400mg Tablets', 'unit': 'boxes', 'bookQty': 25, 'physicalQty': 25, 'wmsBin': 'Store01 - Shelf A1 - Bin 04', 'notes': 'Khớp số liệu quầy (Matched)'},
      ];
      final zoneB = [
        {'sku': 'SKU-B101', 'name': 'Augmentin 1g Tablets', 'unit': 'boxes', 'bookQty': 15, 'physicalQty': 15, 'wmsBin': 'Store01 - Counter B1 - Bin 01', 'notes': 'Khớp số liệu quầy (Matched)'},
        {'sku': 'SKU-B102', 'name': 'Betadine Antiseptic Solution 10%', 'unit': 'bottles', 'bookQty': 12, 'physicalQty': 11, 'wmsBin': 'Store01 - Counter B2 - Bin 02', 'notes': 'Vỡ 1 lọ đang lập biên bản'},
        {'sku': 'SKU-B103', 'name': 'Omeprazole 20mg Capsules', 'unit': 'boxes', 'bookQty': 40, 'physicalQty': 40, 'wmsBin': 'Store01 - Counter B1 - Bin 03', 'notes': 'Khớp số liệu quầy (Matched)'},
        {'sku': 'SKU-B104', 'name': 'Cetirizine 10mg Tablets', 'unit': 'boxes', 'bookQty': 28, 'physicalQty': 28, 'wmsBin': 'Store01 - Counter B3 - Bin 01', 'notes': 'Khớp số liệu quầy (Matched)'},
      ];
      final coldChain = [
        {'sku': 'SKU-C201', 'name': 'Insulin Glargine 100IU/ml (Thuốc lạnh 2-8°C)', 'unit': 'vials', 'bookQty': 8, 'physicalQty': 8, 'wmsBin': 'Store01 - Medical Fridge - Shelf 1', 'notes': 'Nhiệt độ tủ 4.1°C (Khớp số liệu)'},
        {'sku': 'SKU-C202', 'name': 'Hepatitis B Vaccine Recombinant', 'unit': 'vials', 'bookQty': 5, 'physicalQty': 5, 'wmsBin': 'Store01 - Medical Fridge - Shelf 2', 'notes': 'Khớp số liệu quầy (Matched)'},
        {'sku': 'SKU-C203', 'name': 'Oxytocin 10 IU/ml Injection', 'unit': 'ampoules', 'bookQty': 12, 'physicalQty': 12, 'wmsBin': 'Store01 - Medical Fridge - Shelf 1', 'notes': 'Khớp số liệu quầy (Matched)'},
      ];
      if (scope.contains('Zone B')) return zoneB;
      if (scope.contains('Cold Chain')) return coldChain;
      if (scope.contains('Full Annual')) return [...zoneA, ...zoneB, ...coldChain];
      return zoneA;
    }

    // 2. Store 02 (Cau Giay Pharmacy Branch)
    if (branch.contains('Store 02')) {
      final zoneA = [
        {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 60, 'physicalQty': 60, 'wmsBin': 'Store02 - Rack A - Shelf 01', 'notes': 'Khớp số liệu chi nhánh Cầu Giấy'},
        {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 25, 'physicalQty': 25, 'wmsBin': 'Store02 - Rack A - Shelf 02', 'notes': 'Khớp số liệu chi nhánh Cầu Giấy'},
        {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 40, 'physicalQty': 41, 'wmsBin': 'Store02 - Rack A - Shelf 03', 'notes': 'Dư 1 tuýp kiểm kê'},
      ];
      final zoneB = [
        {'sku': 'SKU-B101', 'name': 'Augmentin 1g Tablets', 'unit': 'boxes', 'bookQty': 22, 'physicalQty': 22, 'wmsBin': 'Store02 - Rack B - Shelf 01', 'notes': 'Khớp số liệu'},
        {'sku': 'SKU-B102', 'name': 'Betadine Antiseptic Solution 10%', 'unit': 'bottles', 'bookQty': 18, 'physicalQty': 18, 'wmsBin': 'Store02 - Rack B - Shelf 02', 'notes': 'Khớp số liệu'},
      ];
      final coldChain = [
        {'sku': 'SKU-C201', 'name': 'Insulin Glargine 100IU/ml (Thuốc lạnh 2-8°C)', 'unit': 'vials', 'bookQty': 10, 'physicalQty': 10, 'wmsBin': 'Store02 - Fridge 01 - Zone A', 'notes': 'Nhiệt độ 3.8°C (Khớp số liệu)'},
      ];
      if (scope.contains('Zone B')) return zoneB;
      if (scope.contains('Cold Chain')) return coldChain;
      if (scope.contains('Full Annual')) return [...zoneA, ...zoneB, ...coldChain];
      return zoneA;
    }

    // 3. Warehouse 02 (North Region Distribution)
    if (branch.contains('Warehouse 02')) {
      final zoneA = [
        {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 2200, 'physicalQty': 2200, 'wmsBin': 'NorthHub - Zone A - Pallet 12', 'notes': 'Pallet nguyên tem WMS (Matched)'},
        {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 850, 'physicalQty': 848, 'wmsBin': 'NorthHub - Zone A - Pallet 14', 'notes': 'Thiếu 2 hộp lúc bốc dỡ xe container'},
        {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 1100, 'physicalQty': 1100, 'wmsBin': 'NorthHub - Zone A - Pallet 15', 'notes': 'Khớp số liệu tổng kho'},
      ];
      final zoneB = [
        {'sku': 'SKU-B101', 'name': 'Augmentin 1g Tablets', 'unit': 'boxes', 'bookQty': 950, 'physicalQty': 950, 'wmsBin': 'NorthHub - Zone B - Pallet 04', 'notes': 'Khớp số liệu tổng kho'},
        {'sku': 'SKU-B102', 'name': 'Betadine Antiseptic Solution 10%', 'unit': 'bottles', 'bookQty': 420, 'physicalQty': 420, 'wmsBin': 'NorthHub - Zone B - Pallet 06', 'notes': 'Khớp số liệu tổng kho'},
      ];
      final coldChain = [
        {'sku': 'SKU-C201', 'name': 'Insulin Glargine 100IU/ml (Thuốc lạnh 2-8°C)', 'unit': 'vials', 'bookQty': 350, 'physicalQty': 350, 'wmsBin': 'NorthHub - Cold Room B - Bay 1', 'notes': 'Hệ thống lạnh tự động GSP (Matched)'},
        {'sku': 'SKU-C202', 'name': 'Hepatitis B Vaccine Recombinant', 'unit': 'vials', 'bookQty': 220, 'physicalQty': 220, 'wmsBin': 'NorthHub - Cold Room B - Bay 2', 'notes': 'Khớp số liệu tổng kho'},
      ];
      if (scope.contains('Zone B')) return zoneB;
      if (scope.contains('Cold Chain')) return coldChain;
      if (scope.contains('Full Annual')) return [...zoneA, ...zoneB, ...coldChain];
      return zoneA;
    }

    // 4. Warehouse 01 (Central Hub) & Default
    final zoneA = [
      {'sku': 'SKU-A001', 'name': 'Panadol Extra 500mg', 'unit': 'boxes', 'bookQty': 4500, 'physicalQty': 4500, 'wmsBin': 'Hub01 - Zone A - Rack 01 - Bin A', 'notes': 'Khớp số liệu tổng kho trung tâm (Matched)'},
      {'sku': 'SKU-B002', 'name': 'Amoxicillin 500mg Capsules', 'unit': 'boxes', 'bookQty': 1200, 'physicalQty': 1198, 'wmsBin': 'Hub01 - Zone A - Rack 02 - Bin C', 'notes': 'Thiếu 2 hộp do rách vỏ lúc lấy mẫu QC'},
      {'sku': 'SKU-V003', 'name': 'Vitamin C Sủi 1000mg', 'unit': 'tubes', 'bookQty': 2400, 'physicalQty': 2405, 'wmsBin': 'Hub01 - Zone A - Rack 03 - Bin B', 'notes': 'Dư 5 tuýp chưa nhập sổ WMS'},
      {'sku': 'SKU-I006', 'name': 'Ibuprofen 400mg Tablets', 'unit': 'boxes', 'bookQty': 1500, 'physicalQty': 1500, 'wmsBin': 'Hub01 - Zone A - Rack 01 - Bin D', 'notes': 'Khớp số liệu tổng kho trung tâm'},
    ];
    final zoneB = [
      {'sku': 'SKU-B101', 'name': 'Augmentin 1g Tablets', 'unit': 'boxes', 'bookQty': 2000, 'physicalQty': 2000, 'wmsBin': 'Hub01 - Zone B - Rack 04 - Bin A', 'notes': 'Khớp số liệu tổng kho trung tâm'},
      {'sku': 'SKU-B102', 'name': 'Betadine Antiseptic Solution 10%', 'unit': 'bottles', 'bookQty': 800, 'physicalQty': 797, 'wmsBin': 'Hub01 - Zone B - Rack 05 - Bin B', 'notes': 'Thiếu 3 lọ trong thùng carton'},
      {'sku': 'SKU-B103', 'name': 'Omeprazole 20mg Capsules', 'unit': 'boxes', 'bookQty': 3100, 'physicalQty': 3100, 'wmsBin': 'Hub01 - Zone B - Rack 04 - Bin C', 'notes': 'Khớp số liệu tổng kho trung tâm'},
      {'sku': 'SKU-B104', 'name': 'Cetirizine 10mg Tablets', 'unit': 'boxes', 'bookQty': 1500, 'physicalQty': 1503, 'wmsBin': 'Hub01 - Zone B - Rack 06 - Bin A', 'notes': 'Dư 3 hộp theo thực tế pallet'},
    ];
    final coldChain = [
      {'sku': 'SKU-C201', 'name': 'Insulin Glargine 100IU/ml (Thuốc lạnh 2-8°C)', 'unit': 'vials', 'bookQty': 600, 'physicalQty': 600, 'wmsBin': 'Hub01 - Cold Room A - Fridge 01', 'notes': 'Optimal Temp 4.2°C (Khớp số liệu)'},
      {'sku': 'SKU-C202', 'name': 'Hepatitis B Vaccine Recombinant', 'unit': 'vials', 'bookQty': 400, 'physicalQty': 399, 'wmsBin': 'Hub01 - Cold Room A - Fridge 02Bay', 'notes': 'Vỡ 1 lọ khi vận chuyển ra quầy kiểm định'},
      {'sku': 'SKU-C203', 'name': 'Oxytocin 10 IU/ml Injection', 'unit': 'ampoules', 'bookQty': 900, 'physicalQty': 900, 'wmsBin': 'Hub01 - Cold Room A - Fridge 01Bay', 'notes': 'Khớp số liệu kho lạnh GSP'},
      {'sku': 'SKU-C204', 'name': 'Adrenaline Injection 1mg/ml', 'unit': 'ampoules', 'bookQty': 1100, 'physicalQty': 1100, 'wmsBin': 'Hub01 - Cold Room A - Fridge 03Bay', 'notes': 'Khớp số liệu kho lạnh GSP'},
    ];
    if (scope.contains('Zone B')) return zoneB;
    if (scope.contains('Cold Chain')) return coldChain;
    if (scope.contains('Full Annual')) return [...zoneA, ...zoneB, ...coldChain];
    return zoneA;
  }

  void _onScopeOrBranchChanged({String? scope, String? branch, bool isReload = false}) {
    setState(() {
      if (scope != null) _countMode = scope;
      if (branch != null) _selectedBranch = branch;
      
      // Preservation: Only update note text automatically if user hasn't typed custom notes or when explicitly reloading
      if (_notesController.text.isEmpty || _notesController.text.startsWith('Audit: ') || isReload) {
        _notesController.text = 'Audit: $_countMode • $_selectedBranch';
      }
      _isLoadingList = true;
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _stocktakeItems = _getScopeItems(_countMode, _selectedBranch);
        _isLoadingList = false;
      });

      if (isReload || branch != null || scope != null) {
        String msg = '🔄 Đã đồng bộ và nạp ${_stocktakeItems.length} mã SKU từ WMS cho "$_selectedBranch" (Phạm vi: $_countMode)';
        if (branch != null) msg = '🏢 Đã chuyển sang kho/chi nhánh "$_selectedBranch". Đang hiển thị dữ liệu tồn thực tế.';
        if (scope != null) msg = '📦 Đã chuyển phạm vi kiểm kê sang "$_countMode" tại "$_selectedBranch".';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _submit() {
    int totalVariance = 0;
    for (var item in _stocktakeItems) {
      totalVariance += ((item['physicalQty'] as int) - (item['bookQty'] as int)).abs();
    }

    final dtos = _stocktakeItems.map((e) => StocktakeItemDto(
          medicineId: e['sku'],
          batchId: 'BATCH-2026',
          physicalQuantity: e['physicalQty'],
        )).toList();

    final request = StocktakeRequestDto(
      branchId: _selectedBranch,
      stocktakeDate: DateTime.now().toIso8601String(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : 'Checked $totalVariance units variance',
      items: dtos,
    );
    context.read<StocktakeBloc>().add(StocktakeSubmitted(request));
  }

  @override
  void dispose() {
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
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 28),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Enterprise WMS Cycle Counting & Blind Reconciliation Process', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                                const SizedBox(height: 4),
                                const Text('Blind Count mode conceals book quantities to ensure unbiased physical shelf counts. Multi-level approval sign-off required for inventory adjustment.', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6))),
                              ],
                            ),
                          ),
                        ],
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
                              activeThumbColor: const Color(0xFFD97706),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 1100;
                    final scopeDropdown = DropdownButtonFormField<String>(
                      initialValue: _countMode,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Stocktake Scope (Phạm vi kiểm kê)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF2563EB), size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cycle Count (Zone A - Fast Moving)', child: Text('Cycle Count (Zone A - Fast Moving)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Cycle Count (Zone B - Moderate)', child: Text('Cycle Count (Zone B - Moderate)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Cold Chain Quarantine Zone Check', child: Text('Cold Chain Quarantine Zone Check', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Full Annual Warehouse Stocktake', child: Text('Full Annual Warehouse Stocktake', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: _isLoadingList
                          ? null
                          : (val) {
                              if (val != null) _onScopeOrBranchChanged(scope: val);
                            },
                    );

                    final branchDropdown = DropdownButtonFormField<String>(
                      initialValue: _selectedBranch,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Branch / Warehouse Code (Mã chi nhánh / Kho)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.store_outlined, color: Color(0xFF2563EB), size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Warehouse 01 (Central Hub)', child: Text('Warehouse 01 (Central Hub)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Warehouse 02 (North Region Distribution)', child: Text('Warehouse 02 (North Region Distribution)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Store 01 (Hoan Kiem Pharmacy Branch)', child: Text('Store 01 (Hoan Kiem Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Store 02 (Cau Giay Pharmacy Branch)', child: Text('Store 02 (Cau Giay Pharmacy Branch)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: _isLoadingList
                          ? null
                          : (val) {
                              if (val != null) _onScopeOrBranchChanged(branch: val);
                            },
                    );

                    final notesField = TextField(
                      controller: _notesController,
                      enabled: !_isLoadingList,
                      decoration: const InputDecoration(
                        labelText: 'Stocktake Notes & Audit Reference (Ghi chú & Mã tham chiếu)',
                        hintText: 'Nhập ghi chú chi tiết đợt kiểm kê hoặc mã tham chiếu...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.note_alt_outlined, color: Color(0xFF64748B), size: 20),
                      ),
                    );

                    final reloadButton = ElevatedButton.icon(
                      onPressed: _isLoadingList ? null : () => _onScopeOrBranchChanged(isReload: true),
                      icon: _isLoadingList
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 18),
                      label: Text(_isLoadingList ? 'Đang nạp...' : '🔄 Nạp danh sách'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          scopeDropdown,
                          const SizedBox(height: 12),
                          branchDropdown,
                          const SizedBox(height: 12),
                          if (constraints.maxWidth < 600) ...[
                            notesField,
                            const SizedBox(height: 12),
                            reloadButton,
                          ] else ...[
                            Row(
                              children: [
                                Expanded(child: notesField),
                                const SizedBox(width: 8),
                                reloadButton,
                              ],
                            ),
                          ],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 3, child: scopeDropdown),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: branchDropdown),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: notesField),
                        const SizedBox(width: 12),
                        reloadButton,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
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
                    child: _isLoadingList
                        ? Container(
                            height: 280,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: AppColors.primary),
                                const SizedBox(height: 16),
                                Text(
                                  '⏳ Đang đồng bộ danh sách kiểm kê thực tế từ WMS cho "$_selectedBranch"...',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phạm vi: $_countMode',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, cardConstraints) {
                        final tableWidth = cardConstraints.maxWidth > 850 ? cardConstraints.maxWidth : 850.0;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
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
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
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
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (widget.onBackToDashboard != null) {
                          widget.onBackToDashboard!();
                        } else if (Navigator.of(context).canPop() && ModalRoute.of(context)?.isFirst == false) {
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
