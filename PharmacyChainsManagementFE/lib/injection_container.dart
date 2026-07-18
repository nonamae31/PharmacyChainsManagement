import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/network/api_client.dart';
import 'features/founder_admin/domain/repositories/business_admin_repository.dart';
import 'features/founder_admin/data/repositories/business_admin_repository_impl.dart';
import 'features/founder_admin/domain/usecases/deactivate_business_admin_usecase.dart';
import 'features/founder_admin/presentation/cubit/deactivate_admin_cubit.dart';
import 'features/founder_admin/presentation/cubit/business_admin_cubit.dart';
import 'features/founder_admin/presentation/cubit/create_admin_cubit.dart';

// Revenue Report
import 'features/revenue_report/data/datasources/revenue_report_remote_datasource.dart';
import 'features/revenue_report/data/repositories/revenue_report_repository_impl.dart';
import 'features/revenue_report/domain/repositories/revenue_report_repository.dart';
import 'features/revenue_report/domain/usecases/generate_revenue_report.dart';

// Cash Flow
import 'features/cash_flow/domain/repositories/cash_flow_repository.dart';
import 'features/cash_flow/data/repositories/cash_flow_repository_impl.dart';
import 'features/cash_flow/domain/usecases/get_cash_flow_usecase.dart';
import 'features/cash_flow/data/datasources/cash_flow_remote_datasource.dart';
import 'features/cash_flow/presentation/bloc/cash_flow_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Finance
import 'features/finance/domain/repositories/financial_repository.dart';
import 'features/finance/data/repositories/financial_repository_impl.dart';
import 'features/finance/domain/usecases/export_financial_report_usecase.dart';
import 'features/finance/presentation/cubit/financial_export_cubit.dart';
import 'features/staff_sales/network/staff_sales_api_client.dart';
import 'features/staff_sales/control/staff_sales_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => ApiClient.createDio());
  }
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  }

  // Cubit
  sl.registerFactory(() => BusinessAdminCubit(repository: sl()));
  sl.registerFactory(() => CreateAdminCubit(repository: sl()));
  sl.registerFactory(() => DeactivateAdminCubit(useCase: sl()));
  sl.registerFactory(() => FinancialExportCubit(exportFinancialReportUseCase: sl()));
  sl.registerFactory(() => StaffSalesBloc(apiClient: sl()));

  // Bloc
  sl.registerFactory(() => CashFlowBloc(getCashFlowUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => DeactivateBusinessAdminUseCase(sl()));
  sl.registerLazySingleton(() => GenerateRevenueReportUseCase(sl()));
  sl.registerLazySingleton(() => GetCashFlowUseCase(sl()));
  sl.registerLazySingleton(() => ExportFinancialReportUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BusinessAdminRepository>(
    () => BusinessAdminRepositoryImpl(),
  );
  sl.registerLazySingleton<RevenueReportRepository>(
    () => RevenueReportRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CashFlowRepository>(
    () => CashFlowRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<FinancialRepository>(
    () => FinancialRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<StaffSalesApiClient>(() => StaffSalesApiClient(sl()));

  // Data sources
  sl.registerLazySingleton<RevenueReportRemoteDataSource>(
    () => RevenueReportRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CashFlowRemoteDataSource>(
    () => CashFlowRemoteDataSourceImpl(dio: sl()),
  );
}
