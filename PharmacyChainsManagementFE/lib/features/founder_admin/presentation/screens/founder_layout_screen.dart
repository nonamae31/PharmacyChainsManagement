import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/founder_sidebar.dart';
import '../widgets/founder_bottom_nav.dart';
import 'business_admin_list_view.dart';
import '../cubit/business_admin_cubit.dart';
import '../../data/repositories/business_admin_repository_impl.dart';
import '../../../cash_flow/presentation/screens/cash_flow_screen.dart';
import '../../../revenue_report/presentation/pages/revenue_report_screen.dart';
import '../../../revenue_report/presentation/bloc/revenue_report_bloc.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/screens/founder_profile_screen.dart';
import '../../../profile/presentation/cubit/founder_profile_cubit.dart';
import '../../../profile/presentation/cubit/founder_profile_state.dart';

class FounderLayoutScreen extends StatefulWidget {
  const FounderLayoutScreen({super.key});

  @override
  State<FounderLayoutScreen> createState() => _FounderLayoutScreenState();
}

class _FounderLayoutScreenState extends State<FounderLayoutScreen> {
  int _selectedIndex = 0;

  late final FounderProfileCubit _profileCubit;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _profileCubit = sl<FounderProfileCubit>();
    _profileCubit.loadProfile(''); // load profile info

    _pages = [
      BlocProvider(
        create: (context) => BusinessAdminCubit(repository: BusinessAdminRepositoryImpl()),
        child: const BusinessAdminListView(),
      ),
      BlocProvider(
        create: (context) => sl<RevenueReportBloc>(),
        child: const RevenueReportScreen(),
      ),
      const CashFlowScreen(),
      BlocProvider.value(
        value: _profileCubit,
        child: const FounderProfileScreen(),
      ),
    ];
  }

  Widget _buildTopHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text('Pharmacy Chains Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
          const Spacer(),
          const SizedBox(width: 16),
          BlocBuilder<FounderProfileCubit, FounderProfileState>(
            bloc: _profileCubit,
            builder: (context, state) {
              String name = 'Loading...';
              String role = 'Founder';
              String? avatarUrl;

              if (state is FounderProfileLoaded) {
                name = state.profile.fullName;
                avatarUrl = state.profile.profilePhotoUri;
              } else if (state is FounderProfileUpdateSuccess) {
                name = state.profile.fullName;
                avatarUrl = state.profile.profilePhotoUri;
              } else if (state is FounderProfileError && state.lastProfile != null) {
                name = state.lastProfile!.fullName;
                avatarUrl = state.lastProfile!.profilePhotoUri;
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: (avatarUrl != null && avatarUrl.startsWith('http')) 
                        ? NetworkImage(avatarUrl) 
                        : null,
                    child: (avatarUrl == null || !avatarUrl.startsWith('http'))
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(role, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          appBar: isDesktop ? null : AppBar(title: const Text('Founder Portal')),
          body: Row(
            children: [
              if (isDesktop)
                FounderSidebar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop) _buildTopHeader(),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : FounderBottomNav(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
        );
      },
    );
  }
}
