import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'features/prescription/control/prescription_bloc.dart';
import 'features/prescription/network/prescription_api_client.dart';
import 'features/staff_sales/control/staff_sales_bloc.dart';
import 'features/staff_sales/network/staff_sales_api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core infrastructure.
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => ApiClient.createDio());
  }
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }

  // Staff sales feature.
  sl.registerLazySingleton<StaffSalesApiClient>(
    () => StaffSalesApiClient(sl()),
  );
  sl.registerFactory(() => StaffSalesBloc(apiClient: sl()));

  // Prescription feature used by the staff workspace.
  sl.registerLazySingleton<PrescriptionApiClient>(
    () => PrescriptionApiClient(sl()),
  );
  sl.registerFactory(() => PrescriptionBloc(apiClient: sl()));
}
