import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/business_admin_repository.dart';
import 'business_admin_state.dart';

class BusinessAdminCubit extends Cubit<BusinessAdminState> {
  final BusinessAdminRepository repository;

  BusinessAdminCubit({required this.repository}) : super(BusinessAdminInitial());

  Future<void> fetchBusinessAdmins({bool forceRefresh = false}) async {
    emit(BusinessAdminLoading());
    try {
      final admins = await repository.getBusinessAdmins(forceRefresh: forceRefresh);
      emit(BusinessAdminLoaded(admins: admins));
    } catch (e) {
      emit(BusinessAdminError(message: e.toString()));
    }
  }
}
