import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubit/business_admin_cubit.dart';
import '../cubit/business_admin_state.dart';
import '../../domain/entities/business_admin_entity.dart';
import '../widgets/create_admin_bottom_sheet.dart';
import '../cubit/create_admin_cubit.dart';
import '../widgets/business_admin_edit_bottom_sheet.dart';
import '../widgets/deactivate_admin_dialog.dart';
import '../cubit/deactivate_admin_cubit.dart';
import '../../../../injection_container.dart';

class BusinessAdminListView extends StatefulWidget {
  const BusinessAdminListView({super.key});

  @override
  State<BusinessAdminListView> createState() => _BusinessAdminListViewState();
}

class _BusinessAdminListViewState extends State<BusinessAdminListView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    context.read<BusinessAdminCubit>().fetchBusinessAdmins();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          _showCreateAdminBottomSheet(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: BlocBuilder<BusinessAdminCubit, BusinessAdminState>(
            builder: (context, state) {
              if (state is BusinessAdminLoading || state is BusinessAdminInitial) {
                return _buildSkeleton(context);
              } else if (state is BusinessAdminError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is BusinessAdminLoaded) {
                return _buildContent(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showCreateAdminBottomSheet(BuildContext context) {
    CreateAdminBottomSheet.show(context, () {
      if (!mounted) return;
      context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
    });
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildContentUI(
        context,
        List.generate(5, (index) => const BusinessAdminEntity(
          id: '', name: 'Loading Name', email: 'Loading Email', phone: '', status: 'Active'
        )),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessAdminLoaded state) {
    // Filter admins based on search and status (mocked branch for now)
    final filteredAdmins = state.admins.where((admin) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = admin.name.toLowerCase().contains(searchLower) || admin.email.toLowerCase().contains(searchLower);
      final matchesStatus = _selectedStatus == 'All Status' || admin.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true),
      child: _buildContentUI(context, filteredAdmins),
    );
  }

  Widget _buildContentUI(BuildContext context, List<BusinessAdminEntity> admins) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          const SizedBox(height: 24),
          _buildFilterRow(context),
          const SizedBox(height: 24),
          _buildTotalAdminsCard(admins),
          const SizedBox(height: 24),
          _buildDesktopTable(context, admins),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Oversee and manage regional branch administrators and their access levels.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
      ],
    );

    final buttonWidget = FilledButton.icon(
      onPressed: () => _showCreateAdminBottomSheet(context),
      icon: const Icon(Icons.add),
      label: const Text('Create Business Admin'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [titleWidget, buttonWidget],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: buttonWidget),
        ],
      );
    }
  }

  Widget _buildFilterRow(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    final searchField = TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search administrators...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );

    final statusDropdown = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: ['All Status', 'Active', 'Inactive', 'Deactivated']
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedStatus = val);
      },
    );

    final filterButton = Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
        onPressed: () {},
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(flex: 4, child: searchField),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: statusDropdown),
                  const SizedBox(width: 16),
                  filterButton,
                ],
              )
            : Column(
                children: [
                  searchField,
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: statusDropdown),
                      const SizedBox(width: 16),
                      filterButton,
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTotalAdminsCard(List<BusinessAdminEntity> admins) {
    final now = DateTime.now();
    final addedThisMonth = admins.where((admin) {
      if (admin.createdAt == null) return false;
      return admin.createdAt!.month == now.month && admin.createdAt!.year == now.year;
    }).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Administrators',
                style: TextStyle(
                  color: Color(0xFF4338CA),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    admins.length.toString(),
                    style: const TextStyle(
                      color: Color(0xFF312E81),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      '+$addedThisMonth this month',
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC7D2FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: Color(0xFF4338CA), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<BusinessAdminEntity> admins) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith((states) => const Color(0xFFF8F9FA)),
              dataRowMaxHeight: 72,
              dataRowMinHeight: 72,
              horizontalMargin: 24,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('NAME', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 12))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 12))),
                DataColumn(label: Text('CONTACT', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 12))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 12))),
              ],
              rows: admins.map((admin) {
                final isActive = admin.status.toLowerCase() == 'active';
                final nameParts = admin.name.split(' ');
                final initials = nameParts.length > 1 
                    ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                    : (admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A');

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFE2E8F0),
                            backgroundImage: admin.profilePhotoUri != null && admin.profilePhotoUri!.isNotEmpty
                                ? CachedNetworkImageProvider(admin.profilePhotoUri!)
                                : null,
                            child: admin.profilePhotoUri == null || admin.profilePhotoUri!.isEmpty
                                ? Text(initials, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(admin.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                              Text(admin.email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              admin.status,
                              style: TextStyle(
                                color: isActive ? const Color(0xFF166534) : const Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(admin.phone.isNotEmpty ? admin.phone : 'N/A', style: const TextStyle(color: Color(0xFF475569))),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 20),
                            tooltip: 'Edit',
                            onPressed: () {
                              BusinessAdminEditBottomSheet.show(context, admin, () {
                                if (!mounted) return;
                                context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
                              });
                            },
                          ),
                          if (isActive) ...[
                            IconButton(
                              icon: const Icon(Icons.block_outlined, color: Color(0xFF64748B), size: 20),
                              tooltip: 'Deactivate',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider(
                                    create: (_) => sl<DeactivateAdminCubit>(),
                                    child: DeactivateAdminDialog(adminId: admin.id),
                                  ),
                                ).then((result) {
                                  if (context.mounted && result == true) {
                                    context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                              tooltip: 'Delete',
                              onPressed: () => _handleSoftDelete(context, admin),
                            )
                          ] else
                            IconButton(
                              icon: const Icon(Icons.restore, color: Color(0xFF22C55E), size: 20),
                              tooltip: 'Reactivate',
                              onPressed: () => _handleReactivate(context, admin),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
                  ),
                );
              }
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing 1 to ${admins.length > 10 ? 10 : admins.length} of ${admins.length} entries', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSoftDelete(BuildContext context, BusinessAdminEntity admin) {
    final cubit = context.read<BusinessAdminCubit>();
    cubit.softDeleteBusinessAdmin(admin.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${admin.name}'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            cubit.reactivateBusinessAdmin(admin.id);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleReactivate(BuildContext context, BusinessAdminEntity admin) {
    final cubit = context.read<BusinessAdminCubit>();
    cubit.reactivateBusinessAdmin(admin.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã khôi phục ${admin.name}'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            cubit.softDeleteBusinessAdmin(admin.id);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
