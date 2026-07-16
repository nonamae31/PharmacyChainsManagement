import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/founder_sidebar.dart';
import '../widgets/founder_bottom_nav.dart';
import 'business_admin_list_view.dart';
import '../cubit/business_admin_cubit.dart';
import '../../data/repositories/business_admin_repository_impl.dart';

class FounderLayoutScreen extends StatefulWidget {
  const FounderLayoutScreen({super.key});

  @override
  State<FounderLayoutScreen> createState() => _FounderLayoutScreenState();
}

class _FounderLayoutScreenState extends State<FounderLayoutScreen> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const Center(child: Text('Dashboard Placeholder')),
    BlocProvider(
      create: (context) => BusinessAdminCubit(repository: BusinessAdminRepositoryImpl()),
      child: const BusinessAdminListView(),
    ),
  ];

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
                child: _pages[_selectedIndex],
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
