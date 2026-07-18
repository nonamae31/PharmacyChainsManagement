import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_business_admin_usecase.dart';
import 'business_admin_edit_state.dart';

class BusinessAdminEditCubit extends Cubit<BusinessAdminEditState> {
  final UpdateBusinessAdminUseCase updateBusinessAdminUseCase;

  BusinessAdminEditCubit({required this.updateBusinessAdminUseCase}) : super(BusinessAdminEditInitial());

  Future<void> updateBusinessAdmin({
    required String id,
    required String name,
    required String phone,
    required String email,
  }) async {
    if (state is BusinessAdminEditLoading) return;

    emit(BusinessAdminEditLoading());

    final params = UpdateBusinessAdminParams(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
    );

    try {
      final result = await updateBusinessAdminUseCase(params);
      
      result.fold(
        (failure) => emit(BusinessAdminEditError(message: failure.message)),
        (_) => emit(const BusinessAdminEditSuccess(message: 'Cập nhật tài khoản thành công.')),
      );
    } catch (e) {
      emit(BusinessAdminEditError(message: 'Đã có lỗi xảy ra: $e'));
    }
  }
}
