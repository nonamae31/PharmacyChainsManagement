import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
                return _buildContent(context, state);
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



  Widget _buildSkeleton(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return Skeletonizer(
      enabled: true,
      child: isDesktop 
          ? _buildDesktopTable(List.generate(5, (index) => const BusinessAdminEntity(id: '', name: 'Loading Name', email: 'Loading Email', phone: '', status: 'Active')))
          : _buildMobileList(List.generate(5, (index) => const BusinessAdminEntity(id: '', name: 'Loading Name', email: 'Loading Email', phone: '', status: 'Active'))),
    );
  }

  Widget _buildContent(BuildContext context, BusinessAdminLoaded state) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return Column(
      children: [
        _buildFilterChips(context, state),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true),
            child: isDesktop ? _buildDesktopTable(state.admins) : _buildMobileList(state.admins),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, BusinessAdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AdminFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(filter.name.toUpperCase()),
              selected: state.filter == filter,
              onSelected: (selected) {
                if (selected) {
                  context.read<BusinessAdminCubit>().setFilter(filter);
                }
              },
            ),
          );
        }).toList(),
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
                  backgroundColor: admin.status.toLowerCase() == 'active' ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: admin.status.toLowerCase() == 'active' ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  side: BorderSide.none,
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit',
                      onPressed: () {
                        BusinessAdminEditBottomSheet.show(context, admin, () {
                          context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
                        });
                      },
                    ),
                    if (admin.status.toLowerCase() == 'active') ...[
                      IconButton(
                        icon: const Icon(Icons.block, color: Colors.orange),
                        tooltip: 'Deactivate',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider(
                              create: (_) => sl<DeactivateAdminCubit>(),
                              child: DeactivateAdminDialog(adminId: admin.id),
                            ),
                          ).then((_) {
                            if (context.mounted) {
                              context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Soft Delete',
                        onPressed: () => _handleSoftDelete(context, admin),
                      )
                    ] else
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        tooltip: 'Reactivate',
                        onPressed: () => _handleReactivate(context, admin),
                      ),
                  ],
                ),
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
        final isActive = admin.status.toLowerCase() == 'active';
        final card = Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(admin.email),
            onTap: () {
              BusinessAdminEditBottomSheet.show(context, admin, () {
                context.read<BusinessAdminCubit>().fetchBusinessAdmins(forceRefresh: true);
              });
            },
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

        return Dismissible(
          key: ValueKey('dismiss_${admin.id}_${admin.status}'),
          direction: isActive ? DismissDirection.endToStart : DismissDirection.startToEnd,
          background: isActive ? Container() : Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.restore, color: Colors.white),
          ),
          secondaryBackground: isActive ? Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ) : Container(),
          onDismissed: (direction) {
            if (isActive) {
              _handleSoftDelete(context, admin);
            } else {
              _handleReactivate(context, admin);
            }
          },
          child: card,
        );
      },
    );
  }
}
