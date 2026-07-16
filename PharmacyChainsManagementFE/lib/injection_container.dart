import 'package:get_it/get_it.dart';
import 'features/founder_admin/domain/repositories/business_admin_repository.dart';
import 'features/founder_admin/data/repositories/business_admin_repository_impl.dart';
import 'features/founder_admin/domain/usecases/deactivate_business_admin_usecase.dart';
import 'features/founder_admin/presentation/cubit/deactivate_admin_cubit.dart';
import 'features/founder_admin/presentation/cubit/business_admin_cubit.dart';
import 'features/founder_admin/presentation/cubit/create_admin_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit
  sl.registerFactory(() => BusinessAdminCubit(repository: sl()));
  sl.registerFactory(() => CreateAdminCubit(repository: sl()));
  sl.registerFactory(() => DeactivateAdminCubit(useCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => DeactivateBusinessAdminUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BusinessAdminRepository>(
    () => BusinessAdminRepositoryImpl(),
  );
}
