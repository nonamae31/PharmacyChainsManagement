import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/business_admin_repository.dart';
import '../../data/models/business_admin_request_model.dart';

part 'create_admin_state.dart';

class CreateAdminCubit extends Cubit<CreateAdminState> {
  final BusinessAdminRepository repository;

  CreateAdminCubit({required this.repository}) : super(CreateAdminInitial());

  Future<void> createAdmin(String fullName, String email, String phone) async {
    // E3: Rate Limiting & Debouncing Guard
    if (state is CreateAdminLoading) return;

    emit(CreateAdminLoading());
    try {
      final request = BusinessAdminRequestModel(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      await repository.createBusinessAdmin(request);
      // E5: Phân quyền & Handoff Role
      emit(const CreateAdminSuccess(message: 'Tạo tài khoản Business Admin thành công.'));
    } catch (e) {
      // E6: Offline-first Graceful Degradation
      emit(CreateAdminFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
