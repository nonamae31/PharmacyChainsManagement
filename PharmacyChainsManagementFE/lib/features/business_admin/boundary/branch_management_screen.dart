import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/platform/external_url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_empty_state.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/business_admin_bloc.dart';
import '../control/business_admin_event.dart';
import '../control/business_admin_state.dart';
import '../entity/branch_dto.dart';

enum _BranchViewMode { grid, map }

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final _searchController = TextEditingController();
  _BranchViewMode _viewMode = _BranchViewMode.grid;
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  void _fetchBranches() {
    context.read<BusinessAdminBloc>().add(
      BranchesFetchRequested(search: _searchController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessAdminBloc, BusinessAdminState>(
      listener: (context, state) {
        if (state is BusinessAdminLoadFailure) {
          showAppErrorDialog(context, message: state.message);
        }
      },
      builder: (context, state) {
        if (state is BusinessAdminLoading) return const AppLoadingIndicator();
        if (state is BranchesLoadSuccess) {
          final branches = state.branches;
          final selectedBranch = _selectedBranch(branches);
          return _BranchNetworkContent(
            branches: branches,
            selectedBranch: selectedBranch,
            searchController: _searchController,
            viewMode: _viewMode,
            onSearch: _fetchBranches,
            onRefresh: _fetchBranches,
            onViewModeChanged: (mode) => setState(() => _viewMode = mode),
            onBranchSelected: (branch) =>
                setState(() => _selectedBranchId = branch.branchId),
            onAddBranch: () => _showBranchDialog(context),
            onEditBranch: (branch) =>
                _showBranchDialog(context, branch: branch),
            onAuthorizeBranch: (branch) => _authorizeBranch(context, branch),
          );
        }
        return AppEmptyState(onRetry: _fetchBranches);
      },
    );
  }

  BranchDto? _selectedBranch(List<BranchDto> branches) {
    if (branches.isEmpty) return null;
    return branches.firstWhere(
      (branch) => branch.branchId == _selectedBranchId,
      orElse: () => branches.first,
    );
  }

  void _authorizeBranch(BuildContext context, BranchDto branch) {
    context.read<BusinessAdminBloc>().add(
      BranchUpdateSubmitted(
        branchId: branch.branchId,
        request: BranchRequestDto(
          branchName: branch.branchName,
          address: branch.address,
          phone: branch.phone,
          latitude: branch.latitude,
          longitude: branch.longitude,
          status: 'Active',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _BranchNetworkContent extends StatelessWidget {
  final List<BranchDto> branches;
  final BranchDto? selectedBranch;
  final TextEditingController searchController;
  final _BranchViewMode viewMode;
  final VoidCallback onSearch;
  final VoidCallback onRefresh;
  final ValueChanged<_BranchViewMode> onViewModeChanged;
  final ValueChanged<BranchDto> onBranchSelected;
  final VoidCallback onAddBranch;
  final ValueChanged<BranchDto> onEditBranch;
  final ValueChanged<BranchDto> onAuthorizeBranch;

  const _BranchNetworkContent({
    required this.branches,
    required this.selectedBranch,
    required this.searchController,
    required this.viewMode,
    required this.onSearch,
    required this.onRefresh,
    required this.onViewModeChanged,
    required this.onBranchSelected,
    required this.onAddBranch,
    required this.onEditBranch,
    required this.onAuthorizeBranch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _TopBar(searchController: searchController, onSearch: onSearch),
            const SizedBox(height: AppSpacing.lg),
            _Header(
              branches: branches,
              viewMode: viewMode,
              onRefresh: onRefresh,
              onViewModeChanged: onViewModeChanged,
              onAddBranch: onAddBranch,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (branches.isEmpty)
              const AppEmptyState()
            else if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _BranchCanvas(
                      branches: branches,
                      selectedBranch: selectedBranch,
                      viewMode: viewMode,
                      onBranchSelected: onBranchSelected,
                      onEditBranch: onEditBranch,
                      onOpenMaps: (branch) =>
                          _openBranchInGoogleMaps(context, branch),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 3,
                    child: _BranchInsightPanel(
                      branch: selectedBranch,
                      onOpenMaps: (branch) =>
                          _openBranchInGoogleMaps(context, branch),
                    ),
                  ),
                ],
              )
            else ...[
              _BranchCanvas(
                branches: branches,
                selectedBranch: selectedBranch,
                viewMode: viewMode,
                onBranchSelected: onBranchSelected,
                onEditBranch: onEditBranch,
                onOpenMaps: (branch) =>
                    _openBranchInGoogleMaps(context, branch),
              ),
              const SizedBox(height: AppSpacing.lg),
              _BranchInsightPanel(
                branch: selectedBranch,
                onOpenMaps: (branch) =>
                    _openBranchInGoogleMaps(context, branch),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _ManagerDirectory(
              branches: branches,
              onAuthorizeBranch: onAuthorizeBranch,
              onEditBranch: onEditBranch,
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const _TopBar({required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onSubmitted: (_) => onSearch(),
            decoration: const InputDecoration(
              hintText: 'Search branches, regions, or managers...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton.outlined(
          tooltip: 'Support',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support request noted')),
          ),
          icon: const Icon(Icons.support_agent),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final List<BranchDto> branches;
  final _BranchViewMode viewMode;
  final VoidCallback onRefresh;
  final ValueChanged<_BranchViewMode> onViewModeChanged;
  final VoidCallback onAddBranch;

  const _Header({
    required this.branches,
    required this.viewMode,
    required this.onRefresh,
    required this.onViewModeChanged,
    required this.onAddBranch,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Branch Network',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF0B2F5B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Managing ${branches.length} active locations across the network.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SegmentedButton<_BranchViewMode>(
          segments: const [
            ButtonSegment(
              value: _BranchViewMode.grid,
              icon: Icon(Icons.grid_view),
              label: Text('Grid View'),
            ),
            ButtonSegment(
              value: _BranchViewMode.map,
              icon: Icon(Icons.map_outlined),
              label: Text('Map View'),
            ),
          ],
          selected: {viewMode},
          onSelectionChanged: (value) => onViewModeChanged(value.first),
        ),
        FilledButton.icon(
          onPressed: onAddBranch,
          icon: const Icon(Icons.add_business),
          label: const Text('Authorize Branch Manager'),
        ),
        IconButton.outlined(
          tooltip: AppStrings.refresh,
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _BranchCanvas extends StatelessWidget {
  final List<BranchDto> branches;
  final BranchDto? selectedBranch;
  final _BranchViewMode viewMode;
  final ValueChanged<BranchDto> onBranchSelected;
  final ValueChanged<BranchDto> onEditBranch;
  final ValueChanged<BranchDto> onOpenMaps;

  const _BranchCanvas({
    required this.branches,
    required this.selectedBranch,
    required this.viewMode,
    required this.onBranchSelected,
    required this.onEditBranch,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == _BranchViewMode.map) {
      return _Panel(
        child: SizedBox(
          height: 420,
          child: _NetworkMap(
            branches: branches,
            selectedBranch: selectedBranch,
            onBranchSelected: onBranchSelected,
            onOpenMaps: onOpenMaps,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: branches.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: crossAxisCount == 2 ? 1.65 : 2.25,
          ),
          itemBuilder: (context, index) {
            final branch = branches[index];
            return _BranchCard(
              branch: branch,
              selected: branch.branchId == selectedBranch?.branchId,
              onTap: () => onBranchSelected(branch),
              onEdit: () => onEditBranch(branch),
            );
          },
        );
      },
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchDto branch;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _BranchCard({
    required this.branch,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final status = _branchStatus(branch);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF4FF) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF0B4A7A) : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBadge(icon: Icons.local_pharmacy),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    branch.branchName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusPill(status: status),
                _BranchMenu(branch: branch, onEdit: onEdit),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(branch.address, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_managerName(branch)} | ${branch.phone ?? AppStrings.notAvailable}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
            const Spacer(),
            Row(
              children: [
                _BranchMetric(
                  label: 'Daily Revenue',
                  value: _money(branch.dailyRevenue ?? 0),
                ),
                const Spacer(),
                _BranchMetric(
                  label: 'Staff',
                  value: (branch.staffCount ?? 0).toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchInsightPanel extends StatelessWidget {
  final BranchDto? branch;
  final ValueChanged<BranchDto> onOpenMaps;

  const _BranchInsightPanel({required this.branch, required this.onOpenMaps});

  @override
  Widget build(BuildContext context) {
    if (branch == null) return const AppEmptyState();
    final staffCount = branch!.staffCount ?? 0;
    final stockLevel = math.min(100, 78 + staffCount * 4);
    return Column(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'GEOGRAPHIC FOOTPRINT',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.open_in_full, size: 16),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 180,
                child: _NetworkMap(
                  branches: [branch!],
                  selectedBranch: branch,
                  onBranchSelected: (_) {},
                  onOpenMaps: onOpenMaps,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFF083D66),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOCUS LOCATION',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      branch!.branchName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      branch!.address,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _BranchMetric(
                      label: 'Staff Density',
                      value: staffCount.toString().padLeft(2, '0'),
                      accent: '+${math.max(0, staffCount - 1)}',
                    ),
                  ),
                  Expanded(
                    child: _BranchMetric(
                      label: 'Stock Level',
                      value: '$stockLevel%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(value: stockLevel / 100),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'REVENUE TREND',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 78,
                child: CustomPaint(
                  painter: _BarTrendPainter(branch!.dailyRevenue ?? 0),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => onOpenMaps(branch!),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Google Maps'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManagerDirectory extends StatelessWidget {
  final List<BranchDto> branches;
  final ValueChanged<BranchDto> onAuthorizeBranch;
  final ValueChanged<BranchDto> onEditBranch;

  const _ManagerDirectory({
    required this.branches,
    required this.onAuthorizeBranch,
    required this.onEditBranch,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(
                  'Manager Authorization Directory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Displaying 1-${branches.length} of ${branches.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('MANAGER NAME')),
                DataColumn(label: Text('BRANCH ASSIGNED')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('JOIN DATE')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: branches
                  .map(
                    (branch) => DataRow(
                      cells: [
                        DataCell(_ManagerCell(branch: branch)),
                        DataCell(Text(branch.branchName)),
                        DataCell(_StatusPill(status: _branchStatus(branch))),
                        DataCell(Text(_date(branch.managerJoinedDate))),
                        DataCell(
                          _DirectoryActions(
                            branch: branch,
                            onAuthorizeBranch: onAuthorizeBranch,
                            onEditBranch: onEditBranch,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkMap extends StatelessWidget {
  final List<BranchDto> branches;
  final BranchDto? selectedBranch;
  final ValueChanged<BranchDto> onBranchSelected;
  final ValueChanged<BranchDto> onOpenMaps;

  const _NetworkMap({
    required this.branches,
    required this.selectedBranch,
    required this.onBranchSelected,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        ...branches.asMap().entries.map((entry) {
          final branch = entry.value;
          final position = _mapPosition(branches, branch);
          final selected = branch.branchId == selectedBranch?.branchId;
          return Positioned.fill(
            child: Align(
              alignment: Alignment(position.dx * 2 - 1, position.dy * 2 - 1),
              child: Tooltip(
                message: branch.branchName,
                child: InkWell(
                  onTap: () {
                    onBranchSelected(branch);
                    onOpenMaps(branch);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: selected ? 18 : 14,
                    height: selected ? 18 : 14,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0B4A7A)
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

Offset _mapPosition(List<BranchDto> branches, BranchDto branch) {
  final locatedBranches = branches
      .where((item) => item.latitude != null && item.longitude != null)
      .toList();
  if (branch.latitude == null ||
      branch.longitude == null ||
      locatedBranches.length <= 1) {
    return const Offset(0.5, 0.5);
  }

  final minLatitude = locatedBranches
      .map((item) => item.latitude!)
      .reduce(math.min);
  final maxLatitude = locatedBranches
      .map((item) => item.latitude!)
      .reduce(math.max);
  final minLongitude = locatedBranches
      .map((item) => item.longitude!)
      .reduce(math.min);
  final maxLongitude = locatedBranches
      .map((item) => item.longitude!)
      .reduce(math.max);
  final longitudeRange = math.max(0.0001, maxLongitude - minLongitude);
  final latitudeRange = math.max(0.0001, maxLatitude - minLatitude);
  final x = 0.12 + ((branch.longitude! - minLongitude) / longitudeRange) * 0.76;
  final y = 0.12 + ((maxLatitude - branch.latitude!) / latitudeRange) * 0.76;
  return Offset(x.clamp(0.12, 0.88), y.clamp(0.12, 0.88));
}

class _ManagerCell extends StatelessWidget {
  final BranchDto branch;

  const _ManagerCell({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_managerName(branch)),
            Text(
              branch.managerEmail ?? AppStrings.notAvailable,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _DirectoryActions extends StatelessWidget {
  final BranchDto branch;
  final ValueChanged<BranchDto> onAuthorizeBranch;
  final ValueChanged<BranchDto> onEditBranch;

  const _DirectoryActions({
    required this.branch,
    required this.onAuthorizeBranch,
    required this.onEditBranch,
  });

  @override
  Widget build(BuildContext context) {
    if (branch.status.toLowerCase().contains('pending')) {
      return FilledButton(
        onPressed: () => onAuthorizeBranch(branch),
        child: const Text('Approve'),
      );
    }
    return _BranchMenu(branch: branch, onEdit: () => onEditBranch(branch));
  }
}

class _BranchMenu extends StatelessWidget {
  final BranchDto branch;
  final VoidCallback onEdit;

  const _BranchMenu({required this.branch, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Branch actions',
      onSelected: (value) async {
        if (value == 'edit') onEdit();
        if (value == 'copy') {
          await Clipboard.setData(ClipboardData(text: branch.branchId));
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Branch id copied')));
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit branch')),
        PopupMenuItem(value: 'copy', child: Text('Copy branch id')),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

class _BranchMetric extends StatelessWidget {
  final String label;
  final String value;
  final String? accent;

  const _BranchMetric({required this.label, required this.value, this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (accent != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                accent!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _StatusStyle status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: const Color(0xFF0B4A7A)),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

class _StatusStyle {
  final String label;
  final Color foreground;
  final Color background;

  const _StatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE2E8F0),
    );
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var index = 0; index < 9; index++) {
      final y = size.height * (index + 1) / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), roadPaint);
      final x = size.width * (index + 1) / 10;
      canvas.drawLine(Offset(x, 0), Offset(x - 24, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}

class _BarTrendPainter extends CustomPainter {
  final double revenue;

  const _BarTrendPainter(this.revenue);

  @override
  void paint(Canvas canvas, Size size) {
    final values = [
      revenue * 0.55,
      revenue * 0.42,
      revenue * 0.70,
      revenue,
      revenue * 0.78,
      revenue * 0.62,
    ];
    final maxValue = math.max(1, values.reduce(math.max));
    final barWidth = size.width / (values.length * 1.7);
    for (var index = 0; index < values.length; index++) {
      final height = size.height * values[index] / maxValue;
      final left = index * barWidth * 1.7;
      final color = index == 3 ? const Color(0xFF0B4A7A) : AppColors.border;
      canvas.drawRect(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarTrendPainter oldDelegate) =>
      oldDelegate.revenue != revenue;
}

_StatusStyle _branchStatus(BranchDto branch) {
  final value = branch.status.toLowerCase();
  if (value.contains('pending')) {
    return const _StatusStyle(
      label: 'Pending Review',
      foreground: AppColors.warning,
      background: Color(0xFFFFF3CD),
    );
  }
  if (value.contains('inactive')) {
    return const _StatusStyle(
      label: 'Inactive',
      foreground: AppColors.danger,
      background: Color(0xFFFFE4E6),
    );
  }
  return const _StatusStyle(
    label: 'Authorized',
    foreground: AppColors.success,
    background: Color(0xFFDCFCE7),
  );
}

String _managerName(BranchDto branch) =>
    branch.managerName?.trim().isNotEmpty == true
    ? branch.managerName!
    : 'Unassigned Manager';

String _money(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < rounded.length; index++) {
    final remaining = rounded.length - index;
    buffer.write(rounded[index]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return '\$$buffer';
}

String _date(DateTime? date) {
  if (date == null) return AppStrings.notAvailable;
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
}

Future<void> _openBranchInGoogleMaps(
  BuildContext context,
  BranchDto branch,
) async {
  final uri = _googleMapsUri(branch);
  final opened = await openExternalUrl(uri);
  if (opened || !context.mounted) return;
  await Clipboard.setData(ClipboardData(text: uri.toString()));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Google Maps link copied')));
}

Uri _googleMapsUri(BranchDto branch) {
  final latitude = branch.latitude;
  final longitude = branch.longitude;
  final query = latitude != null && longitude != null
      ? '$latitude,$longitude'
      : '${branch.branchName}, ${branch.address}';
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
}

void _showBranchDialog(BuildContext context, {BranchDto? branch}) {
  final nameController = TextEditingController(text: branch?.branchName ?? '');
  final addressController = TextEditingController(text: branch?.address ?? '');
  final phoneController = TextEditingController(text: branch?.phone ?? '');

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(branch == null ? 'New branch' : 'Edit branch'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Branch name'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final request = BranchRequestDto(
              branchName: nameController.text.trim(),
              address: addressController.text.trim(),
              phone: phoneController.text.trim(),
              latitude: branch?.latitude,
              longitude: branch?.longitude,
              status: branch?.status ?? 'Active',
            );
            final bloc = context.read<BusinessAdminBloc>();
            if (branch == null) {
              bloc.add(BranchCreateSubmitted(request));
            } else {
              bloc.add(
                BranchUpdateSubmitted(
                  branchId: branch.branchId,
                  request: request,
                ),
              );
            }
            Navigator.of(dialogContext).pop();
          },
          child: const Text(AppStrings.saveChanges),
        ),
      ],
    ),
  );
}
