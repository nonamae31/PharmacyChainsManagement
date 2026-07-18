import 'package:flutter/material.dart';
import '../../inventory/boundary/inventory_dashboard_screen.dart';
import '../../inventory/control/inventory_dashboard_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/network/secure_storage_service.dart';
import '../../inventory/network/inventory_api_client.dart';
import '../../inventory/control/stocktake_bloc.dart';
import '../../inventory/control/receive_goods_bloc.dart';
import '../../inventory/control/issue_stock_bloc.dart';
import '../../auth/control/auth_bloc.dart';
import '../../auth/control/auth_event.dart';
import '../../auth/control/auth_state.dart';
import '../../auth/boundary/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          title: Text('Pharmacy Chains - $role'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              key: const Key('logoutButton'),
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 32,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Quản lý kho\n(Inventory)',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    onTap: () {
                      final dio = Dio(BaseOptions(
                        baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:7000',
                        connectTimeout: const Duration(seconds: 15),
                        receiveTimeout: const Duration(seconds: 15),
                        headers: {'Content-Type': 'application/json'},
                      ));
                      dio.interceptors.add(
                        InterceptorsWrapper(
                          onRequest: (options, handler) async {
                            final token = await SecureStorageService.readToken();
                            if (token != null) {
                              options.headers['Authorization'] = 'Bearer $token';
                            }
                            return handler.next(options);
                          },
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider<InventoryDashboardBloc>(
                                create: (context) => InventoryDashboardBloc(InventoryApiClient(dio)),
                              ),
                              BlocProvider<StocktakeBloc>(
                                create: (context) => StocktakeBloc(InventoryApiClient(dio)),
                              ),
                              BlocProvider<ReceiveGoodsBloc>(
                                create: (context) => ReceiveGoodsBloc(InventoryApiClient(dio)),
                              ),
                              BlocProvider<IssueStockBloc>(
                                create: (context) => IssueStockBloc(InventoryApiClient(dio)),
                              ),
                            ],
                            child: const InventoryDashboardScreen(branchId: '00000000-0000-0000-0000-000000000000'),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Bán hàng\n(POS)',
                    icon: Icons.point_of_sale,
                    color: Colors.green,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Báo cáo\n(Reports)',
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Cài đặt\n(Settings)',
                    icon: Icons.settings_outlined,
                    color: Colors.blueGrey,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
