import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../cubit/business_admin_cubit.dart';
import '../cubit/business_admin_state.dart';
import '../../domain/entities/business_admin_entity.dart';
import '../widgets/create_admin_bottom_sheet.dart';
import '../cubit/create_admin_cubit.dart';
import '../widgets/deactivate_admin_dialog.dart';
import '../cubit/deactivate_admin_cubit.dart';
import '../../../../injection_container.dart';

class BusinessAdminListView extends StatefulWidget {
  const BusinessAdminListView({super.key});

  @override
  State<BusinessAdminListView> createState() => _BusinessAdminListViewState();
}

class _BusinessAdminListViewState extends State<BusinessAdminListView> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessAdminCubit>().fetchBusinessAdmins();
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
          body: BlocBuilder<BusinessAdminCubit, BusinessAdminState>(
            builder: (context, state) {
              if (state is BusinessAdminLoading || state is BusinessAdminInitial) {
                return _buildSkeleton(context);
              } else if (state is BusinessAdminError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is BusinessAdminLoaded) {
                return _buildContent(context, state.admins);
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('add_admin_fab'),
            tooltip: 'Add Admin',
            onPressed: () => _showCreateAdminBottomSheet(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showCreateAdminBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<CreateAdminCubit>(),
          child: CreateAdminBottomSheet(
            onSuccess: () {
              context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeactivateDialog(BuildContext context, String adminId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<DeactivateAdminCubit>(),
          child: DeactivateAdminDialog(adminId: adminId),
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vô hiệu hóa thành công.'), backgroundColor: Colors.green),
      );
      context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
    }
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return Skeletonizer(
      enabled: true,
      child: isDesktop 
          ? _buildDesktopTable(List.generate(5, (index) => const BusinessAdminEntity(id: '', name: 'Loading Name', email: 'Loading Email', status: 'Active')))
          : _buildMobileList(List.generate(5, (index) => const BusinessAdminEntity(id: '', name: 'Loading Name', email: 'Loading Email', status: 'Active'))),
    );
  }

  Widget _buildContent(BuildContext context, List<BusinessAdminEntity> admins) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return RefreshIndicator(
      onRefresh: () => context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true),
      child: isDesktop ? _buildDesktopTable(admins) : _buildMobileList(admins),
    );
  }

  Widget _buildDesktopTable(List<BusinessAdminEntity> admins) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith((states) => Theme.of(context).colorScheme.surfaceContainerHighest),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: admins.map((admin) => DataRow(
            cells: [
              DataCell(Text(admin.name)),
              DataCell(Text(admin.email)),
              DataCell(
                Chip(
                  label: Text(admin.status),
                  backgroundColor: admin.status == 'Active' ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: admin.status == 'Active' ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  side: BorderSide.none,
                ),
              ),
              DataCell(
                admin.status == 'Active'
                    ? IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: 'Deactivate',
                        onPressed: () => _showDeactivateDialog(context, admin.id),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<BusinessAdminEntity> admins) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        final isActive = admin.status == 'Active';
        final card = Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(admin.email),
            trailing: Chip(
              label: Text(admin.status),
              backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
              labelStyle: TextStyle(
                color: isActive ? Colors.green.shade800 : Colors.red.shade800,
              ),
              side: BorderSide.none,
            ),
          ),
        );

        if (!isActive) return card;

        return Dismissible(
          key: ValueKey('dismiss_${admin.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.block, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            await _showDeactivateDialog(context, admin.id);
            return false; // Dialog fetches data, no need to actually dismiss UI element here
          },
          child: card,
        );
      },
    );
  }
}
