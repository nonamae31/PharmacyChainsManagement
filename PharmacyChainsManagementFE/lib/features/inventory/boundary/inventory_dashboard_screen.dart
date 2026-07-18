import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/inventory_dashboard_bloc.dart';
import '../control/inventory_dashboard_event.dart';
import '../control/inventory_dashboard_state.dart';
import 'package:dio/dio.dart';
import '../network/inventory_api_client.dart';
import '../control/stocktake_bloc.dart';
import '../control/receive_goods_bloc.dart';
import '../control/issue_stock_bloc.dart';
import 'widgets/inventory_summary_card.dart';
import 'qc_inspection_screen.dart';
import 'internal_transfer_approval_screen.dart';
import 'stocktake_screen.dart';
import 'expired_stock_management_screen.dart';
import 'batch_expiry_management_screen.dart';
import 'inventory_report_screen.dart';

class InventoryDashboardScreen extends StatefulWidget {
  final String branchId;

  const InventoryDashboardScreen({super.key, required this.branchId});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  int _selectedIndex = 6; // Default to 'Safety Stock'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Optimal', 'Low Stock', 'Critical'

  // Dynamic User Profile State
  String _userName = 'Inventory Manager';
  String _userFullName = 'Nguyễn Văn Hoàng';
  String _userEmail = 'hoang.nv@pharmacychains.vn';
  String _userPhone = '+84 988 123 456';
  String _userBranch = 'Warehouse 01 - FPT Campus';
  bool _emailAlertsEnabled = true;
  bool _smsAlertsEnabled = false;

  // Dynamic Local Inventory List for Interactive Testing
  late List<Map<String, dynamic>> _inventoryList;

  @override
  void initState() {
    super.initState();
    context.read<InventoryDashboardBloc>().add(InventoryDashboardFetchRequested(widget.branchId));
    
    // Initialize rich interactive inventory data
    _inventoryList = [
      {
        'sku': 'SKU-P001',
        'name': 'Panadol Extra 500mg',
        'currentStock': 450,
        'safetyStock': 500,
        'reorderPt': 550,
        'suggested': '+100 boxes',
        'status': 'Low Stock',
        'statusColor': const Color(0xFFF59E0B),
        'unit': 'boxes',
        'selected': false,
        'supplier': 'GSK Pharma Vietnam',
      },
      {
        'sku': 'SKU-A002',
        'name': 'Amoxicillin 500mg',
        'currentStock': 1200,
        'safetyStock': 800,
        'reorderPt': 1000,
        'suggested': '0',
        'status': 'Optimal',
        'statusColor': const Color(0xFF10B981),
        'unit': 'capsules',
        'selected': false,
        'supplier': 'Dược Hậu Giang (DHG)',
      },
      {
        'sku': 'SKU-V003',
        'name': 'Vitamin C Sủi 1000mg',
        'currentStock': 8,
        'safetyStock': 50,
        'reorderPt': 60,
        'suggested': '+50 tubes',
        'status': 'Critical',
        'statusColor': const Color(0xFFEF4444),
        'unit': 'tubes',
        'selected': false,
        'supplier': 'Bayer Vietnam',
      },
      {
        'sku': 'SKU-M004',
        'name': 'Khẩu trang y tế 4 lớp N95',
        'currentStock': 3000,
        'safetyStock': 1000,
        'reorderPt': 1500,
        'suggested': '0',
        'status': 'Optimal',
        'statusColor': const Color(0xFF10B981),
        'unit': 'packs',
        'selected': false,
        'supplier': 'MedPro Medicals',
      },
      {
        'sku': 'SKU-O005',
        'name': 'Omez 20mg Capsules',
        'currentStock': 120,
        'safetyStock': 200,
        'reorderPt': 250,
        'suggested': '+100 boxes',
        'status': 'Low Stock',
        'statusColor': const Color(0xFFF59E0B),
        'unit': 'boxes',
        'selected': false,
        'supplier': 'Dr. Reddy\'s Lab',
      },
      {
        'sku': 'SKU-I006',
        'name': 'Ibuprofen 400mg Tablets',
        'currentStock': 15,
        'safetyStock': 100,
        'reorderPt': 120,
        'suggested': '+100 boxes',
        'status': 'Critical',
        'statusColor': const Color(0xFFEF4444),
        'unit': 'boxes',
        'selected': false,
        'supplier': 'Sanofi Aventis',
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter items dynamically based on search & status filter
  List<Map<String, dynamic>> get _filteredList {
    return _inventoryList.where((item) {
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['sku'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || item['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _updateStockStatus(Map<String, dynamic> item) {
    final current = item['currentStock'] as int;
    final safety = item['safetyStock'] as int;
    final reorder = item['reorderPt'] as int;

    if (current <= safety * 0.3) {
      item['status'] = 'Critical';
      item['statusColor'] = const Color(0xFFEF4444);
      item['suggested'] = '+${(reorder - current) + 50} ${item['unit']}';
    } else if (current <= safety) {
      item['status'] = 'Low Stock';
      item['statusColor'] = const Color(0xFFF59E0B);
      item['suggested'] = '+${reorder - current} ${item['unit']}';
    } else {
      item['status'] = 'Optimal';
      item['statusColor'] = const Color(0xFF10B981);
      item['suggested'] = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // LEFT SIDEBAR
          _buildSidebar(),
          
          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: BlocConsumer<InventoryDashboardBloc, InventoryDashboardState>(
                    listener: (context, state) {
                      if (state is InventoryDashboardLoadFailure) {
                        showAppErrorDialog(context, message: state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is InventoryDashboardLoading) {
                        return const Center(child: AppLoadingIndicator());
                      }

                      return MultiBlocProvider(
                        providers: [
                          BlocProvider<StocktakeBloc>(
                            create: (context) => StocktakeBloc(InventoryApiClient(Dio())),
                          ),
                          BlocProvider<ReceiveGoodsBloc>(
                            create: (context) => ReceiveGoodsBloc(InventoryApiClient(Dio())),
                          ),
                          BlocProvider<IssueStockBloc>(
                            create: (context) => IssueStockBloc(InventoryApiClient(Dio())),
                          ),
                        ],
                        child: _buildMainBody(state),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIDEBAR WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LogisticsPro',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      'Warehouse 01',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildSidebarItem(0, 'Dashboard (Tổng quan)', Icons.dashboard_outlined),
                  _buildSidebarItem(1, 'Receive Goods (Nhập hàng)', Icons.move_to_inbox_outlined),
                  _buildSidebarItem(2, 'QC Inspection (Kiểm tra CL)', Icons.fact_check_outlined),
                  _buildSidebarItem(3, 'Issue Stock (Xuất hàng)', Icons.outbox_outlined),
                  _buildSidebarItem(4, 'Internal Transfers (Chuyển kho)', Icons.swap_horiz_outlined),
                  _buildSidebarItem(5, 'Stocktake (Kiểm kê)', Icons.assignment_outlined),
                  _buildSidebarItem(6, 'Safety Stock (Tồn an toàn)', Icons.warning_amber_rounded, isAlert: true),
                  _buildSidebarItem(7, 'Expired/Damaged (Hết hạn)', Icons.remove_circle_outline),
                  _buildSidebarItem(8, 'Batch Tracking (Tra cứu lô)', Icons.qr_code_2_outlined),
                  _buildSidebarItem(9, 'Reports (Báo cáo)', Icons.bar_chart_outlined),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildBottomSidebarItem('Profile (Hồ sơ)', Icons.person_outline, _showUserProfileDialog),
                _buildBottomSidebarItem('Logout (Đăng xuất)', Icons.logout_outlined, () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, {bool isAlert = false}) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? const Border(left: BorderSide(color: Color(0xFF2563EB), width: 4)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF2563EB) : (isAlert ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF2563EB) : (isAlert ? const Color(0xFF0284C7) : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSidebarItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Interactive Search Box
          Container(
            width: 320,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search SKU or Product...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                            )
                          : null,
                    ),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'Inventory Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),

          // Right Controls & User Info
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                    onPressed: _showNotificationsDialog,
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 16),
              InkWell(
                onTap: _showUserProfileDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(_userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                      const SizedBox(width: 12),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF3B82F6),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN CONTENT BODY & INTERACTIVE PANELS
  // ---------------------------------------------------------------------------
  Widget _buildMainBody(InventoryDashboardState state) {
    if (_selectedIndex == 2) return const QcInspectionScreen();
    if (_selectedIndex == 4) return const InternalTransferApprovalScreen();
    if (_selectedIndex == 5) return const StocktakeScreen();
    if (_selectedIndex == 7) return const ExpiredStockManagementScreen();
    if (_selectedIndex == 8) return const BatchExpiryManagementScreen();
    if (_selectedIndex == 9) return const InventoryReportScreen();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interactive menu content switcher
          if (_selectedIndex == 0) ...[
            if (state is InventoryDashboardLoadSuccess) InventorySummaryCard(valuation: state.valuation),
            const SizedBox(height: 24),
            _buildDashboardAnalyticsWidget(),
          ] else if (_selectedIndex == 1) ...[
            _buildReceiveGoodsPortal(),
          ] else if (_selectedIndex == 3) ...[
            _buildIssueStockPortal(),
          ] else ...[
            // SAFETY STOCK / INVENTORY TABLE VIEW
            _buildTableSection(),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLE SECTION & CONTROLS
  // ---------------------------------------------------------------------------
  Widget _buildTableSection() {
    final items = _filteredList;
    final selectedCount = _inventoryList.where((e) => e['selected'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _getMenuTitle(_selectedIndex),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 12),
                if (_statusFilter != 'All')
                  Chip(
                    label: Text('Filter: $_statusFilter', style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _statusFilter = 'All'),
                    backgroundColor: const Color(0xFFDBEAFE),
                  ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: Text(_statusFilter == 'All' ? 'Filter Status' : _statusFilter),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddSkuDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add SKU / Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Bulk Actions Bar (if checkboxes checked)
        if (selectedCount > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$selectedCount SKU(s) selected for batch action', style: const TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showToast('Đã tạo đơn đặt hàng nhanh cho $selectedCount sản phẩm!');
                        setState(() {
                          for (var item in _inventoryList) {
                            if (item['selected'] == true) {
                              item['currentStock'] = (item['currentStock'] as int) + 200;
                              _updateStockStatus(item);
                              item['selected'] = false;
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      child: const Text('Bulk Reorder (+200)'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        for (var item in _inventoryList) item['selected'] = false;
                      }),
                      child: const Text('Clear Selection'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),

        // DATA TABLE
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Checkbox(
                        value: items.isNotEmpty && items.every((e) => e['selected'] == true),
                        onChanged: (val) {
                          setState(() {
                            for (var item in items) item['selected'] = val ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(flex: 3, child: _buildTableHeaderText('PRODUCT / SKU')),
                    Expanded(flex: 2, child: _buildTableHeaderText('CURRENT STOCK')),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          'SAFETY STOCK',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: _buildTableHeaderText('REORDER PT.')),
                    Expanded(flex: 2, child: _buildTableHeaderText('SUGGESTED')),
                    Expanded(flex: 2, child: _buildTableHeaderText('STATUS')),
                    Expanded(flex: 2, child: _buildTableHeaderText('ACTIONS', alignRight: true)),
                  ],
                ),
              ),

              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  alignment: Alignment.center,
                  child: const Text('No matching SKU products found.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                )
              else
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return _buildTableRow(
                    item: item,
                    isLast: idx == items.length - 1,
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderText(String text, {bool alignRight = false}) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
    );
  }

  Widget _buildTableRow({required Map<String, dynamic> item, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: item['selected'] == true,
              onChanged: (val) {
                setState(() {
                  item['selected'] = val ?? false;
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item['sku']} • ${item['supplier']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${item['currentStock']} ${item['unit']}', style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('${item['safetyStock']} ${item['unit']}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(flex: 2, child: Text('${item['reorderPt']} ${item['unit']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
          Expanded(
            flex: 2,
            child: Text(
              item['suggested'],
              style: TextStyle(
                color: item['suggested'] == '0' ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                fontWeight: item['suggested'] == '0' ? FontWeight.normal : FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (item['statusColor'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    item['status'],
                    style: TextStyle(color: item['statusColor'], fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showQuickOrderDialog(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    foregroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Order', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                  onPressed: () => _showStockAdjustDialog(item),
                  tooltip: 'Điều chỉnh nhanh số lượng kho',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE MODALS & DIALOGS
  // ---------------------------------------------------------------------------

  void _showAddSkuDialog() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController(text: 'SKU-NEW0${_inventoryList.length + 1}');
    final currentCtrl = TextEditingController(text: '500');
    final safetyCtrl = TextEditingController(text: '300');
    final reorderCtrl = TextEditingController(text: '400');
    final supplierCtrl = TextEditingController(text: 'AstraZeneca Vietnam');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New SKU Product to Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name *', hintText: 'e.g. Paracetamol 500mg')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU Code'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: currentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current Stock'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: safetyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Safety Stock'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: reorderCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder Pt.'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newItem = {
                'sku': skuCtrl.text.trim(),
                'name': nameCtrl.text.trim(),
                'currentStock': int.tryParse(currentCtrl.text) ?? 0,
                'safetyStock': int.tryParse(safetyCtrl.text) ?? 100,
                'reorderPt': int.tryParse(reorderCtrl.text) ?? 150,
                'suggested': '0',
                'status': 'Optimal',
                'statusColor': const Color(0xFF10B981),
                'unit': 'boxes',
                'selected': false,
                'supplier': supplierCtrl.text.trim(),
              };
              _updateStockStatus(newItem);

              setState(() {
                _inventoryList.insert(0, newItem);
              });
              Navigator.pop(ctx);
              _showToast('Đã thêm sản phẩm mới "${newItem['name']}" thành công!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Save SKU'),
          ),
        ],
      ),
    );
  }

  void _showQuickOrderDialog(Map<String, dynamic> item) {
    int qty = (item['reorderPt'] as int) - (item['currentStock'] as int);
    if (qty < 50) qty = 100;
    final qtyCtrl = TextEditingController(text: qty.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quick Purchase Order (PO) - ${item['sku']}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('Supplier: ${item['supplier']}', style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Order Quantity (${item['unit']})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Đơn hàng sẽ được gửi trực tiếp đến hệ thống ERP của nhà cung cấp.', style: TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final added = int.tryParse(qtyCtrl.text) ?? 100;
              setState(() {
                item['currentStock'] = (item['currentStock'] as int) + added;
                _updateStockStatus(item);
              });
              Navigator.pop(ctx);
              _showToast('Đã tạo PO nhập thêm +$added ${item['unit']} cho "${item['name']}"!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustDialog(Map<String, dynamic> item) {
    final qtyCtrl = TextEditingController(text: item['currentStock'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Stock - ${item['name']}'),
        content: SizedBox(
          width: 350,
          child: TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Actual Stock Quantity', border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['currentStock'] = int.tryParse(qtyCtrl.text) ?? 0;
                _updateStockStatus(item);
              });
              Navigator.pop(ctx);
              _showToast('Đã cập nhật lại số lượng thực tế của "${item['name']}"!');
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Filter by Inventory Status'),
        children: ['All', 'Optimal', 'Low Stock', 'Critical'].map((status) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _statusFilter = status);
              Navigator.pop(ctx);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(_statusFilter == status ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Text(status, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Warehouse Alerts & Logs'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAlertRow('⚠️ SKU-V003 Vitamin C Sủi is critical (8 tubes left)!', 'Just now'),
              _buildAlertRow('📦 PO-20260715 from GSK arrived at loading bay.', '10m ago'),
              _buildAlertRow('ℹ️ Stocktake report verified for Warehouse 01.', '2h ago'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildAlertRow(String text, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)))),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showUserProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final fullNameCtrl = TextEditingController(text: _userFullName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final branchCtrl = TextEditingController(text: _userBranch);
    bool tempEmailAlerts = _emailAlertsEnabled;
    bool tempSmsAlerts = _smsAlertsEnabled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.person, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userFullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('Warehouse Head Manager • EMP-VN-8821', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('THÔNG TIN CÁ NHÂN (PERSONAL INFO)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Display Name / Tên hiển thị', border: OutlineInputBorder(), isDense: true))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Full Name / Họ tên đầy đủ', border: OutlineInputBorder(), isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Work Email', border: OutlineInputBorder(), isDense: true))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Assigned Branch / Chi nhánh phụ trách', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 16),
                  const Text('CÀI ĐẶT BẢO MẬT & THÔNG BÁO (PREFERENCES)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Nhận cảnh báo tồn kho qua Email (Email Alerts)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Tự động gửi thông báo khi sản phẩm xuống mức Critical', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    value: tempEmailAlerts,
                    onChanged: (val) => setDialogState(() => tempEmailAlerts = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Nhận tin nhắn SMS khi có lô hàng mới (PO Arrival)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    value: tempSmsAlerts,
                    onChanged: (val) => setDialogState(() => tempSmsAlerts = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showChangePasswordDialog();
                    },
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Đổi mật khẩu tài khoản (Change Password)'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy bỏ (Cancel)')),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _userName = nameCtrl.text.trim();
                  _userFullName = fullNameCtrl.text.trim();
                  _userEmail = emailCtrl.text.trim();
                  _userPhone = phoneCtrl.text.trim();
                  _userBranch = branchCtrl.text.trim();
                  _emailAlertsEnabled = tempEmailAlerts;
                  _smsAlertsEnabled = tempSmsAlerts;
                });
                Navigator.pop(ctx);
                _showToast('✅ Đã lưu thay đổi hồ sơ: "$_userName" thành công!');
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Lưu hồ sơ (Save Changes)'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu bảo mật', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới *', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (newPassCtrl.text.isNotEmpty && newPassCtrl.text == confirmPassCtrl.text) {
                Navigator.pop(ctx);
                _showToast('🔒 Đã cập nhật mật khẩu mới thành công!');
              } else {
                _showToast('❌ Mật khẩu xác nhận không khớp!');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            child: const Text('Cập nhật mật khẩu'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE PORTALS FOR OTHER SIDEBAR MENUS
  // ---------------------------------------------------------------------------
  Widget _buildDashboardAnalyticsWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Critical Stock Alerts require immediate PO order:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          ..._inventoryList.where((e) => e['status'] == 'Critical').map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['name']} (${item['sku']}) - Only ${item['currentStock']} left!', style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w600)),
                    ElevatedButton(
                      onPressed: () => _showQuickOrderDialog(item),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                      child: const Text('Reorder Now'),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReceiveGoodsPortal() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Receive Goods Portal (Nhập hàng từ NCC / Vào kho)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          const Text('Select product and enter new batch quantity arrived from vendor (Chọn sản phẩm và nhập số lượng lô mới đến từ NCC):', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          ..._inventoryList.map((item) => ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('SKU: ${item['sku']} | Current Stock (Tồn hiện có): ${item['currentStock']} ${item['unit']}'),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    _showQuickOrderDialog(item);
                  },
                  icon: const Icon(Icons.add_box, size: 18),
                  label: const Text('Receive Batch / Nhập lô (+100)'),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildIssueStockPortal() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Issue Stock Portal (Xuất kho bán hàng / Phân phối về Store)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 24),
          ..._inventoryList.map((item) => ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('SKU: ${item['sku']} | Available Stock (Tồn khả dụng): ${item['currentStock']} ${item['unit']}'),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    if ((item['currentStock'] as int) >= 10) {
                      setState(() {
                        item['currentStock'] = (item['currentStock'] as int) - 10;
                        _updateStockStatus(item);
                      });
                      _showToast('Đã xuất -10 ${item['unit']} của "${item['name']}"!');
                    } else {
                      _showToast('Không đủ hàng trong kho để xuất!');
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('Issue Stock / Xuất kho (-10)'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                ),
              )),
        ],
      ),
    );
  }

  String _getMenuTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard Overview (Tổng quan Kho)';
      case 1: return 'Receive Goods Portal (Nhập hàng từ NCC)';
      case 2: return 'QC Inspection Management (Kiểm tra Chất lượng GSP)';
      case 3: return 'Issue Stock Portal (Xuất hàng về Store)';
      case 4: return 'Inter-Branch Stock Transfers (Chuyển kho Nội bộ)';
      case 5: return 'Stocktake Management (Kiểm kê Thực tế)';
      case 6: return 'Safety Stock Alerts (Quản lý Tồn kho An toàn)';
      case 7: return 'Expired & Damaged Stock (Thuốc Hết hạn & Hư hỏng)';
      case 8: return 'Batch Traceability & Tracking (Tra cứu Số lô & Hạn dùng)';
      case 9: return 'Inventory Reports & Analytics (Báo cáo Thống kê & Định giá)';
      default: return 'Safety Stock Alerts (Quản lý Tồn kho An toàn)';
    }
  }
}
