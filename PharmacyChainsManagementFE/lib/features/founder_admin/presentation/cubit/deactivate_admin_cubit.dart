import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/deactivate_business_admin_usecase.dart';
import 'deactivate_admin_state.dart';

class DeactivateAdminCubit extends Cubit<DeactivateAdminState> {
  final DeactivateBusinessAdminUseCase useCase;

  DeactivateAdminCubit({required this.useCase}) : super(DeactivateAdminInitial());

  Future<void> deactivateAdmin(String id, String reason) async {
    if (state is DeactivateAdminLoading) return;
    
    emit(DeactivateAdminLoading());
    
    final result = await useCase(id, reason);
    
    result.fold(
      (failure) => emit(DeactivateAdminFailure(error: failure.message)),
      (_) => emit(const DeactivateAdminSuccess(message: 'Vô hiệu hóa thành công.')),
    );
  }
}
