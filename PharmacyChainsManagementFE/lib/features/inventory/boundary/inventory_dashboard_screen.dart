import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
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

  // Dynamic Local Inventory List for Interactive Testing
  late List<Map<String, dynamic>> _inventoryList;
  late List<Map<String, dynamic>> _branchDispatchOrders;

  @override
  void initState() {
    super.initState();
    context.read<InventoryDashboardBloc>().add(InventoryDashboardFetchRequested(widget.branchId));
    
    // Initialize rich interactive inventory data with WMS/Pharma Enterprise fields
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
        'abcClass': 'Class A',
        'xyzClass': 'X (Stable Demand)',
        'demandForecast': '+18% surge (Flu Season peak)',
        'wmsLocation': 'Zone A - Rack 04 - Bin B02',
        'fefoBatch': 'LOT-2026-GSK-081 (Exp: 01/2027)',
        'leadTimeDays': 3,
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
        'abcClass': 'Class A',
        'xyzClass': 'Y (Moderate Fluctuation)',
        'demandForecast': '+5% steady hospital orders',
        'wmsLocation': 'Zone A - Rack 02 - Bin A01',
        'fefoBatch': 'LOT-2025-DHG-442 (Exp: 08/2026)',
        'leadTimeDays': 4,
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
        'abcClass': 'Class B',
        'xyzClass': 'Z (Volatile Demand)',
        'demandForecast': '+35% high seasonal surge',
        'wmsLocation': 'Zone B - Rack 01 - Bin C05',
        'fefoBatch': 'LOT-2024-BYR-109 (Exp: 11/2026)',
        'leadTimeDays': 2,
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
        'abcClass': 'Class C',
        'xyzClass': 'X (Stable Demand)',
        'demandForecast': 'Stable baseline consumption',
        'wmsLocation': 'Zone C - Bulk Storage Pallet 09',
        'fefoBatch': 'LOT-2026-MED-990 (Exp: 12/2029)',
        'leadTimeDays': 5,
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
        'abcClass': 'Class B',
        'xyzClass': 'Y (Moderate Fluctuation)',
        'demandForecast': '+8% regular clinic replenishment',
        'wmsLocation': 'Zone B - Rack 03 - Bin D02',
        'fefoBatch': 'LOT-2025-DRL-551 (Exp: 05/2027)',
        'leadTimeDays': 3,
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
        'abcClass': 'Class A',
        'xyzClass': 'Z (Volatile Demand)',
        'demandForecast': '+22% high prescription rate',
        'wmsLocation': 'Zone A - Rack 01 - Bin A04',
        'fefoBatch': 'LOT-2025-SNF-302 (Exp: 03/2027)',
        'leadTimeDays': 2,
      },
    ];

    _branchDispatchOrders = [
      {
        'orderId': 'REQ-20260718-01',
        'targetStore': 'Store #01 - Pharmacity Nguyễn Thị Minh Khai (Q.1)',
        'requestDate': '2026-07-18 08:00 AM',
        'priority': 'Khẩn cấp (Urgent)',
        'status': 'Đang nhặt hàng (Picking in Progress)',
        'items': [
          {
            'sku': 'SKU-P001',
            'name': 'Panadol Extra 500mg',
            'unit': 'boxes',
            'requestedQty': 100,
            'issuedQty': 60,
          },
          {
            'sku': 'SKU-A002',
            'name': 'Amoxicillin 500mg',
            'unit': 'capsules',
            'requestedQty': 200,
            'issuedQty': 200,
          },
        ],
      },
      {
        'orderId': 'REQ-20260718-02',
        'targetStore': 'Store #05 - Nhà thuốc Long Châu Hai Bà Trưng (Q.3)',
        'requestDate': '2026-07-18 09:15 AM',
        'priority': 'Bình thường (Normal)',
        'status': 'Chờ xuất kho (Pending Dispatch)',
        'items': [
          {
            'sku': 'SKU-M004',
            'name': 'Khẩu trang y tế 4 lớp N95',
            'unit': 'packs',
            'requestedQty': 150,
            'issuedQty': 0,
          },
          {
            'sku': 'SKU-O005',
            'name': 'Omez 20mg Capsules',
            'unit': 'boxes',
            'requestedQty': 40,
            'issuedQty': 0,
          },
        ],
      },
      {
        'orderId': 'REQ-20260718-03',
        'targetStore': 'Store #12 - An Khang Lê Văn Sỹ (Q.Tân Bình)',
        'requestDate': '2026-07-18 10:30 AM',
        'priority': 'Bình thường (Normal)',
        'status': 'Chờ xuất kho (Pending Dispatch)',
        'items': [
          {
            'sku': 'SKU-I006',
            'name': 'Ibuprofen 400mg Tablets',
            'unit': 'boxes',
            'requestedQty': 25,
            'issuedQty': 0,
          },
        ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pharmacy Chains Management • ${_getMenuTitle(_selectedIndex).split(' (')[0]}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                      const Text('Central Warehouse 01', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B), size: 22),
                      onPressed: _showNotificationsDialog,
                    ),
                    InkWell(
                      onTap: _showUserProfileDialog,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, left: 4),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(isMobile: !isDesktop),
                    Expanded(
                      child: MultiBlocProvider(
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
                        child: BlocListener<InventoryDashboardBloc, InventoryDashboardState>(
                          listener: (context, state) {
                            if (state is InventoryDashboardLoadFailure) {
                              showAppErrorDialog(context, message: state.message);
                            }
                          },
                          child: _buildMainBody(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
        );
      },
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacy Chains Management',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Central Warehouse 01',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go('/login');
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
    final alertCount = _inventoryList.where((e) => e['status'] == 'Critical').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : isAlert
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                  ),
                ),
              ),
              if (isAlert && alertCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$alertCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569)), overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildTopBar({bool isMobile = false}) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm SKU hoặc Thuốc...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
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
      );
    }

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

          Flexible(
            child: const Text(
              'Pharmacy Chains Management • WMS Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              overflow: TextOverflow.ellipsis,
            ),
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
  Widget _buildMainBody() {
    if (_selectedIndex == 2) return const QcInspectionScreen();
    if (_selectedIndex == 4) return const InternalTransferApprovalScreen();
    if (_selectedIndex == 5) return StocktakeScreen(onBackToDashboard: () => setState(() => _selectedIndex = 0));
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
            BlocBuilder<InventoryDashboardBloc, InventoryDashboardState>(
              builder: (context, state) {
                if (state is InventoryDashboardLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: AppLoadingIndicator()));
                }
                if (state is InventoryDashboardLoadSuccess) {
                  return InventorySummaryCard(valuation: state.valuation);
                }
                return const SizedBox.shrink();
              },
            ),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1050),
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
                      width: 36,
                      child: Checkbox(
                        value: items.isNotEmpty && items.every((e) => e['selected'] == true),
                        onChanged: (val) {
                          setState(() {
                            for (var item in items) item['selected'] = val ?? false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 210, child: _buildTableHeaderText('PRODUCT / SKU')),
                    SizedBox(width: 110, child: _buildTableHeaderText('ABC / XYZ')),
                    SizedBox(width: 130, child: _buildTableHeaderText('WMS LOCATION')),
                    SizedBox(width: 110, child: _buildTableHeaderText('STOCK')),
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          'SAFETY / ROP',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8), letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    SizedBox(width: 160, child: _buildTableHeaderText('AI DEMAND FORECAST')),
                    SizedBox(width: 120, child: _buildTableHeaderText('STATUS')),
                    SizedBox(width: 170, child: _buildTableHeaderText('ACTIONS', alignRight: true)),
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
    final abc = item['abcClass'] ?? 'Class B';
    final xyz = item['xyzClass'] ?? 'Y';
    final wmsLoc = item['wmsLocation'] ?? 'Zone A - Rack 1';
    final forecast = item['demandForecast'] ?? 'Stable';
    final leadTime = item['leadTimeDays'] ?? 3;
    final rop = item['reorderPt'] ?? 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Checkbox(
              value: item['selected'] == true,
              onChanged: (val) {
                setState(() {
                  item['selected'] = val ?? false;
                });
              },
            ),
          ),
          SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14)),
                const SizedBox(height: 2),
                Text('${item['sku']} • ${item['supplier']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: abc == 'Class A' ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(abc, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: abc == 'Class A' ? const Color(0xFFB45309) : const Color(0xFF475569))),
                ),
                const SizedBox(height: 2),
                Text(xyz, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(wmsLoc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
          ),
          SizedBox(
            width: 110,
            child: Text('${item['currentStock']} ${item['unit']}', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety: ${item['safetyStock']}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.w600)),
                Text('ROP: $rop (LT:${leadTime}d)', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 4),
                Expanded(child: Text(forecast, style: const TextStyle(fontSize: 12, color: Color(0xFF6D28D9), fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          SizedBox(
            width: 120,
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
          SizedBox(
            width: 170,
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
              if (nameCtrl.text.trim().isEmpty) {
                _showToast('⚠️ Vui lòng nhập tên thuốc (Medicine Name không được để trống!)');
                return;
              }
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
              _showToast('✅ Đã thêm sản phẩm mới "${newItem['name']}" thành công!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Save SKU'),
          ),
        ],
      ),
    );
  }

    void _showProofImageSelectorModal(BuildContext parentCtx, Map<String, dynamic> item, StateSetter setDialogState) {
    showModalBottomSheet(
      context: parentCtx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (selectorCtx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text('📸 Chọn ảnh minh chứng gửi cho Business Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Vui lòng chọn hình ảnh thực tế Phiếu giao hàng hoặc Kiện hàng để xác nhận số liệu nhập kho chuẩn xác:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF2563EB)),
              ),
              title: const Text('📄 Phiếu giao hàng & Hóa đơn VAT nhà cung cấp', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('phieu_giao_hang_GSK_batch081.jpg • 1.2 MB', style: TextStyle(fontSize: 12)),
              onTap: () {
                setDialogState(() => item['proofImage'] = 'phieu_giao_hang_GSK_batch081.jpg');
                setState(() => item['proofImage'] = 'phieu_giao_hang_GSK_batch081.jpg');
                Navigator.pop(selectorCtx);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF10B981)),
              ),
              title: const Text('📦 Kiện thuốc nguyên seal & Mã vạch GS1 DataMatrix', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('thung_panadol_inbound_box.jpg • 2.4 MB', style: TextStyle(fontSize: 12)),
              onTap: () {
                setDialogState(() => item['proofImage'] = 'thung_panadol_inbound_box.jpg');
                setState(() => item['proofImage'] = 'thung_panadol_inbound_box.jpg');
                Navigator.pop(selectorCtx);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xFFEF4444)),
              ),
              title: const Text('🔬 Phiếu kiểm nghiệm chất lượng COA từ nhà máy', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('tem_kiem_dinh_COA_lab.jpg • 1.8 MB', style: TextStyle(fontSize: 12)),
              onTap: () {
                setDialogState(() => item['proofImage'] = 'tem_kiem_dinh_COA_lab.jpg');
                setState(() => item['proofImage'] = 'tem_kiem_dinh_COA_lab.jpg');
                Navigator.pop(selectorCtx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickOrderDialog(Map<String, dynamic> item) {
    int qty = item['receiveBatchQty'] ?? ((item['reorderPt'] as int) - (item['currentStock'] as int));
    if (qty <= 0) qty = 100;
    final qtyCtrl = TextEditingController(text: qty.toString());
    final batchCtrl = TextEditingController(text: item['batchNumber'] ?? 'LOT-2026-GSK-081');
    final notesCtrl = TextEditingController(text: 'Bao bì nguyên seal, kiểm tra nhiệt độ bảo quản 2-8°C đạt chuẩn');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inbox, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              Expanded(child: Text('WMS Inbound & Proof Verification - ${item['sku']}')),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('Supplier: ${item['supplier']} | WMS Putaway: ${item['wmsLocation'] ?? "Zone A - Rack 01"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Receive Qty (${item['unit']})',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.add_shopping_cart, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: batchCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Supplier Batch Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.qr_code_2, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Inspector Notes / Ghi chú kiểm định',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 📸 PROOF IMAGE SECTION FOR BUSINESS ADMIN VERIFICATION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item['proofImage'] != null ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: item['proofImage'] != null ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                        width: item['proofImage'] != null ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(item['proofImage'] != null ? Icons.verified : Icons.camera_alt, color: item['proofImage'] != null ? const Color(0xFF16A34A) : const Color(0xFF2563EB), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  item['proofImage'] != null ? '📸 Ảnh minh chứng xác minh số liệu' : '📸 Gửi ảnh xác minh cho Business Admin',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: item['proofImage'] != null ? const Color(0xFF16A34A) : const Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                            if (item['proofImage'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                                child: const Text('Sẵn sàng gửi Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['proofImage'] != null
                              ? 'Đã chọn ảnh Phiếu giao hàng / Thùng thuốc thực tế. Business Admin có thể đối chiếu chính xác số lượng và lô hàng.'
                              : 'Business Admin yêu cầu nhân viên kho đính kèm hình ảnh thực tế Phiếu giao hàng hoặc Kiện hàng để xác minh số liệu nhập kho.',
                          style: TextStyle(fontSize: 12, color: item['proofImage'] != null ? const Color(0xFF15803D) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        if (item['proofImage'] == null) ...[
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showProofImageSelectorModal(ctx, item, setDialogState),
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('📷 Chụp ảnh thực tế'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () => _showProofImageSelectorModal(ctx, item, setDialogState),
                                icon: const Icon(Icons.folder_open, size: 16),
                                label: const Text('📁 Chọn Phiếu / COA'),
                                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBBF7D0))),
                            child: Row(
                              children: [
                                const Icon(Icons.image, color: Color(0xFF16A34A), size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${item['proofImage']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF16A34A))),
                                      const Text('Đã kiểm tra chất lượng • Chờ Business Admin xác minh', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Color(0xFF2563EB), size: 20),
                                  tooltip: 'Đổi ảnh khác',
                                  onPressed: () => _showProofImageSelectorModal(ctx, item, setDialogState),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                  tooltip: 'Xóa ảnh',
                                  onPressed: () {
                                    setDialogState(() => item['proofImage'] = null);
                                    setState(() => item['proofImage'] = null);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Số lượng nhập, mã lô và ảnh xác minh sẽ lập tức được ghi nhận vào nhật ký kho GSP và gửi thông báo tới Business Admin.', style: TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                final added = int.tryParse(qtyCtrl.text) ?? 100;
                setState(() {
                  item['receiveBatchQty'] = added;
                  item['currentStock'] = (item['currentStock'] as int) + added;
                  _updateStockStatus(item);
                });
                Navigator.pop(ctx);
                if (item['proofImage'] != null) {
                  _showToast('✅ Đã nhập +$added ${item['unit']} kèm ảnh minh chứng "${item['proofImage']}" cho Business Admin xác minh!');
                } else {
                  _showToast('✅ Đã cập nhật lô nhập +$added ${item['unit']} (Chưa kèm ảnh. Vui lòng bổ sung minh chứng sau)!');
                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Confirm Receive Batch & Submit Proof'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickAdjustDialog(Map<String, dynamic> item) {
    int qty = item['issueBatchQty'] ?? 10;
    final qtyCtrl = TextEditingController(text: qty.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Picking Quantity - ${item['sku']}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Picking / Issue Quantity (${item['unit']})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_shipping_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final pickQty = int.tryParse(qtyCtrl.text) ?? 10;
              setState(() {
                item['issueBatchQty'] = pickQty;
              });
              Navigator.pop(ctx);
              _showToast('✅ Đã cấu hình mức xuất (-$pickQty ${item['unit']}) cho "${item['name']}"!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
            child: const Text('Save Pick Quantity'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PHARMA WMS KPI METRICS ROW
        Row(
          children: [
            Expanded(child: _buildKpiCard('Inventory Turnover', '4.2x / yr', '+0.5 vs target', Icons.loop, const Color(0xFF3B82F6))),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Days Inv. Outstanding (DIO)', '86 Days', 'Optimal cycle', Icons.calendar_today, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Order Fill Rate', '98.4%', 'Target > 98%', Icons.check_circle_outline, const Color(0xFF8B5CF6))),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Stock Accuracy', '99.1%', 'Post-stocktake', Icons.verified_outlined, const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 24),

        // 3. WAREHOUSE CAPACITY HEATMAP & ZONES
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Warehouse Capacity Heatmap by Zones (Sức chứa & Phân khu GSP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildHeatmapBar('Zone A (Fast Moving / ABC Class A)', 0.95, const Color(0xFFEF4444), '95% Full (High Load)')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildHeatmapBar('Zone B (Moderate Moving / Class B)', 0.60, const Color(0xFF3B82F6), '60% Full (Optimal)')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildHeatmapBar('Zone C (Bulk / Cold Storage)', 0.20, const Color(0xFF10B981), '20% Full (Available)')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildHeatmapBar('Quarantine Zone Q (QC / Damaged)', 0.15, const Color(0xFFF59E0B), '15% Quarantined')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. TOP CRITICAL ALERTS & RECALL WARNINGS
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top Critical Alerts & Urgent Actions (PO Reorder / QC / Recalls):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              ..._inventoryList.where((e) => e['status'] == 'Critical').map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('🚨 [CRITICAL STOCK] ${item['name']} (${item['sku']}) - Only ${item['currentStock']} left! (ROP: ${item['reorderPt']})', style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w600)),
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
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(subtitle, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapBar(String zoneName, double ratio, Color color, String statusText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(zoneName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildReceiveGoodsPortal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. ADVANCE SHIPPING NOTICE (ASN) & WMS PUTAWAY RECOMMENDATION
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📦 Advance Shipping Notice (ASN) & Vendor Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showShortageDiscrepancyModal(),
                        icon: const Icon(Icons.report_problem_outlined, size: 18, color: Color(0xFFEF4444)),
                        label: const Text('Report Shortage / Over Delivery', style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🟢 ASN #ASN-20260718-01: 5 Pallets arrived from GSK Pharma (ETA: 08:30 AM) - Status: Offloading & Temperature Verified', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    Text('Putaway Recommendation: Zone A - Rack 04', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. RECEIVE GOODS ITEM LIST WITH PUTAWAY SUGGESTION
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WMS Inbound Inspection & Batch Putaway (Nhập hàng & Đề xuất vị trí cất)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              ..._inventoryList.map((item) {
                final receiveQty = item['receiveBatchQty'] ?? ((item['reorderPt'] as int) - (item['currentStock'] as int) > 0 ? (item['reorderPt'] as int) - (item['currentStock'] as int) : 100);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  title: Text('${item['name']} (${item['sku']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Current Stock: ${item['currentStock']} ${item['unit']} | Vendor: ${item['supplier']}'),
                      const SizedBox(height: 2),
                      Text('📍 WMS Putaway Recommendation: ${item['wmsLocation'] ?? "Zone A - Rack 01 - Bin B"}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                      if (item['proofImage'] != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF22C55E))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF15803D)),
                              const SizedBox(width: 4),
                              Text('📸 Minh chứng: ${item['proofImage']} (Chờ Admin duyệt)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showQuickOrderDialog(item),
                        icon: Icon(item['proofImage'] != null ? Icons.photo_camera : Icons.add_a_photo_outlined, size: 16, color: const Color(0xFF2563EB)),
                        label: Text(item['proofImage'] != null ? '📸 Đổi ảnh xác minh' : '📸 Gửi ảnh xác minh'),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showQuickOrderDialog(item),
                        icon: const Icon(Icons.add_box, size: 18),
                        label: Text('Receive Batch / Nhập lô (+$receiveQty)'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Đổi con số lô nhập (+X) & gửi ảnh',
                        icon: const Icon(Icons.edit_note, color: Color(0xFF2563EB), size: 24),
                        onPressed: () => _showQuickOrderDialog(item),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIssueStockPortal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. FEFO ENGINE & PICKING LIST BANNER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🚚 FEFO Engine Allocation & WMS Picking List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ElevatedButton.icon(
                    onPressed: () => _showPickingPackingSimulator(),
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text('Verify Picking & Packing Sealing'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
                child: const Row(
                  children: [
                    Icon(Icons.rule, color: Color(0xFFB45309), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('FEFO Rule Active & Strict Branch Allocation: Xuất kho tuân thủ nghiêm ngặt theo đúng số lượng Phiếu yêu cầu từ Branch/Store. Hệ thống ưu tiên tự động lô cận date (FEFO) và khóa nút xuất khi đã đạt hạn mức, chống thao tác nhầm lẫn hay ấn bừa.', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. BRANCH DISPATCH ORDERS LIST
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outbound Picking & Branch Dispatch (Xuất kho theo Phiếu Yêu cầu từ Branch/Store)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      SizedBox(height: 4),
                      Text('Danh sách các phiếu yêu cầu cung ứng hàng từ các chi nhánh/cửa hàng trong chuỗi', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        // Reset demo orders
                        _branchDispatchOrders[0]['items'][0]['issuedQty'] = 60;
                        _branchDispatchOrders[0]['items'][1]['issuedQty'] = 200;
                        _branchDispatchOrders[0]['status'] = 'Đang nhặt hàng (Picking in Progress)';
                        _branchDispatchOrders[1]['items'][0]['issuedQty'] = 0;
                        _branchDispatchOrders[1]['items'][1]['issuedQty'] = 0;
                        _branchDispatchOrders[1]['status'] = 'Chờ xuất kho (Pending Dispatch)';
                        _branchDispatchOrders[2]['items'][0]['issuedQty'] = 0;
                        _branchDispatchOrders[2]['status'] = 'Chờ xuất kho (Pending Dispatch)';
                      });
                      _showToast('Đã làm mới danh sách phiếu yêu cầu từ Branch/Store!');
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Làm mới phiếu Yêu cầu'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._branchDispatchOrders.map((order) {
                final isUrgent = (order['priority'] as String).contains('Khẩn cấp');
                final isCompleted = (order['status'] as String).contains('Sẵn sàng giao') || (order['status'] as String).contains('Hoàn tất');

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isCompleted ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isCompleted ? const Color(0xFFBBF7D0) : const Color(0xFFCBD5E1), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFDCFCE7) : (isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFE2E8F0)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle : (isUrgent ? Icons.error_outline : Icons.local_shipping),
                                  color: isCompleted ? const Color(0xFF16A34A) : (isUrgent ? const Color(0xFFDC2626) : const Color(0xFF334155)),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Mã yêu cầu: ${order['orderId']} • ${order['targetStore']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isUrgent && !isCompleted ? const Color(0xFF991B1B) : const Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFF15803D)
                                        : (isUrgent ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    isCompleted ? '✅ Đã nhặt đủ - Sẵn sàng giao Store' : '${order['priority']} | ${order['status']}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text('🕒 Thời gian gửi yêu cầu: ${order['requestDate']}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                      ),
                      const Divider(height: 20),

                      // Order Items Table / List
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (order['items'] as List<Map<String, dynamic>>).map((subItem) {
                            // Find matching WMS item in inventory
                            final matchingInvIndex = _inventoryList.indexWhere((inv) => inv['sku'] == subItem['sku']);
                            final invItem = matchingInvIndex != -1 ? _inventoryList[matchingInvIndex] : null;

                            final reqQty = subItem['requestedQty'] as int;
                            final issuedQty = subItem['issuedQty'] as int;
                            final remainingQty = reqQty - issuedQty;
                            final isItemFulfilled = issuedQty >= reqQty;
                            final currentStock = invItem != null ? (invItem['currentStock'] as int) : 0;
                            final fefoBatch = invItem != null ? invItem['fefoBatch'] : 'LOT-2026-STD-100 (Exp: 12/2027)';
                            final wmsBin = invItem != null ? invItem['wmsLocation'] : 'Zone B - Rack 02 - Bin A01';

                            return Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isItemFulfilled ? const Color(0xFFDCFCE7).withOpacity(0.5) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isItemFulfilled ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '📦 ${subItem['name']} (${subItem['sku']})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                      ),
                                      if (isItemFulfilled)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(12)),
                                          child: Text('✅ Đã xuất đủ theo yêu cầu ($reqQty/$reqQty ${subItem['unit']})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        )
                                      else
                                        Text(
                                          '⚠️ Store yêu cầu: $reqQty ${subItem['unit']} • Đã nhặt: $issuedQty • Còn lại: $remainingQty ${subItem['unit']}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text('📍 Vị trí WMS: $wmsBin', style: const TextStyle(fontSize: 13, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 16),
                                      Text('🏷️ Lô FEFO ưu tiên: $fefoBatch', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                                      const SizedBox(width: 16),
                                      Text('📊 Tồn kho thực tế: $currentStock ${subItem['unit']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: currentStock < remainingQty ? const Color(0xFFEF4444) : const Color(0xFF10B981))),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: reqQty > 0 ? (issuedQty / reqQty).clamp(0.0, 1.0) : 1.0,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(isItemFulfilled ? const Color(0xFF16A34A) : const Color(0xFFF59E0B)),
                                      minHeight: 8,
                                    ),
                                  ),
                                  if (!isItemFulfilled) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text('Hạn mức xuất theo Store: ', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            final pickAmt = remainingQty >= 10 ? 10 : remainingQty;
                                            if (currentStock < pickAmt) {
                                              _showToast('❌ Kho không đủ số lượng thực tế ($currentStock ${subItem['unit']}) để xuất!');
                                              return;
                                            }
                                            setState(() {
                                              subItem['issuedQty'] = issuedQty + pickAmt;
                                              if (invItem != null) {
                                                invItem['currentStock'] = currentStock - pickAmt;
                                                _updateStockStatus(invItem);
                                              }
                                              // Check if all order items fulfilled
                                              final allDone = (order['items'] as List).every((i) => (i['issuedQty'] as int) >= (i['requestedQty'] as int));
                                              if (allDone) {
                                                order['status'] = 'Sẵn sàng giao Store (Ready for Delivery)';
                                              } else {
                                                order['status'] = 'Đang nhặt hàng (Picking in Progress)';
                                              }
                                            });
                                            _showToast('Đã xuất -$pickAmt ${subItem['unit']} cho Store "${order['targetStore']}"!');
                                          },
                                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                                          label: Text('Nhặt phần (-${remainingQty >= 10 ? 10 : remainingQty})'),
                                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD97706), side: const BorderSide(color: Color(0xFFD97706))),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            if (currentStock < remainingQty) {
                                              _showToast('❌ Kho không đủ số lượng ($currentStock ${subItem['unit']}) để xuất trọn bộ $remainingQty ${subItem['unit']}!');
                                              return;
                                            }
                                            setState(() {
                                              subItem['issuedQty'] = reqQty;
                                              if (invItem != null) {
                                                invItem['currentStock'] = currentStock - remainingQty;
                                                _updateStockStatus(invItem);
                                              }
                                              final allDone = (order['items'] as List).every((i) => (i['issuedQty'] as int) >= (i['requestedQty'] as int));
                                              if (allDone) {
                                                order['status'] = 'Sẵn sàng giao Store (Ready for Delivery)';
                                              } else {
                                                order['status'] = 'Đang nhặt hàng (Picking in Progress)';
                                              }
                                            });
                                            _showToast('✅ Đã xuất đủ trọn gói $reqQty ${subItem['unit']} theo đúng Phiếu yêu cầu!');
                                          },
                                          icon: const Icon(Icons.check_circle_outline, size: 16),
                                          label: Text('Xuất đủ theo Yêu cầu (-$remainingQty ${subItem['unit']})'),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }


  void _showShortageDiscrepancyModal() {
    final poQtyCtrl = TextEditingController(text: '1000');
    final actualQtyCtrl = TextEditingController(text: '970');
    final reasonCtrl = TextEditingController(text: '3 outer cartons damaged and missing during carrier transport');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Record Shortage / Over Delivery Discrepancy', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: poQtyCtrl, decoration: const InputDecoration(labelText: 'PO Book Quantity (Số lượng theo đơn PO)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: actualQtyCtrl, decoration: const InputDecoration(labelText: 'Actual Received Quantity (Số lượng nhận thực tế)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: reasonCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Discrepancy Reason & Note', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('📋 Recorded Shortage discrepancy (-30 boxes). Claim sent to vendor!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Submit Discrepancy Report'),
          ),
        ],
      ),
    );
  }

  void _showPickingPackingSimulator() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📦 WMS Picking, Packing & Sealing Verification', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 1: Picking verification at Zone A - Rack 04 [VERIFIED]', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Step 2: FEFO Batch Lot check against Dispatch Order [MATCHED]', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Step 3: Security Sealing & Temper-evident tape check [CONFIRMED]', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Digital e-Signature verified by Pharmacist on duty.', style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showToast('🚀 Dispatch order sealed & moved to In-Transit stage!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
            child: const Text('Approve & Dispatch Shipment'),
          ),
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

  // ---------------------------------------------------------------------------
  // MOBILE RESPONSIVE BOTTOM NAV & MORE MENU
  // ---------------------------------------------------------------------------
  Widget _buildMobileBottomNav() {
    int bottomIndex = 0;
    if (_selectedIndex == 0) bottomIndex = 0;
    else if (_selectedIndex == 1) bottomIndex = 1;
    else if (_selectedIndex == 3) bottomIndex = 2;
    else if (_selectedIndex == 5) bottomIndex = 3;
    else bottomIndex = 4;

    return NavigationBar(
      selectedIndex: bottomIndex,
      onDestinationSelected: (index) {
        if (index == 0) setState(() => _selectedIndex = 0);
        else if (index == 1) setState(() => _selectedIndex = 1);
        else if (index == 2) setState(() => _selectedIndex = 3);
        else if (index == 3) setState(() => _selectedIndex = 5);
        else if (index == 4) _showMobileMoreMenuBottomSheet();
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Color(0xFF2563EB)),
          label: 'Tổng quan',
        ),
        NavigationDestination(
          icon: Icon(Icons.move_to_inbox_outlined),
          selectedIcon: Icon(Icons.move_to_inbox, color: Color(0xFF2563EB)),
          label: 'Nhập hàng',
        ),
        NavigationDestination(
          icon: Icon(Icons.outbox_outlined),
          selectedIcon: Icon(Icons.outbox, color: Color(0xFF2563EB)),
          label: 'Xuất hàng',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: Color(0xFF2563EB)),
          label: 'Kiểm kê',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu),
          selectedIcon: Icon(Icons.menu_open, color: Color(0xFF2563EB)),
          label: 'Tất cả',
        ),
      ],
    );
  }

  void _showMobileMoreMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('📦 Các phân hệ quản lý kho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ),
              const Divider(),
              _buildMobileMenuOption(ctx, 2, 'QC Inspection (Kiểm tra chất lượng)', Icons.fact_check_outlined),
              _buildMobileMenuOption(ctx, 4, 'Internal Transfers (Chuyển kho nội bộ)', Icons.swap_horiz_outlined),
              _buildMobileMenuOption(ctx, 6, 'Safety Stock (Cảnh báo tồn an toàn)', Icons.warning_amber_rounded, isAlert: true),
              _buildMobileMenuOption(ctx, 7, 'Expired/Damaged (Hàng hết hạn/hư hỏng)', Icons.remove_circle_outline),
              _buildMobileMenuOption(ctx, 8, 'Batch Tracking (Tra cứu lô thuốc GS1)', Icons.qr_code_2_outlined),
              _buildMobileMenuOption(ctx, 9, 'Reports (Báo cáo & Phân tích GSP)', Icons.bar_chart_outlined),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
                title: const Text('Profile (Hồ sơ người dùng)', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUserProfileDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text('Logout (Đăng xuất)', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuOption(BuildContext ctx, int index, String title, IconData icon, {bool isAlert = false}) {
    final isSelected = _selectedIndex == index;
    final alertCount = _inventoryList.where((e) => e['status'] == 'Critical').length;

    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF2563EB) : (isAlert ? const Color(0xFFEF4444) : const Color(0xFF64748B))),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155))),
      trailing: isAlert && alertCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(10)),
              child: Text('$alertCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          : (isSelected ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(ctx);
      },
    );
  }
}
