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
      emit(BusinessAdminLoaded(allAdmins: admins));
    } catch (e) {
      emit(BusinessAdminError(message: e.toString()));
    }
  }

  void setFilter(AdminFilter filter) {
    if (state is BusinessAdminLoaded) {
      emit((state as BusinessAdminLoaded).copyWith(filter: filter));
    }
  }

  Future<void> softDeleteBusinessAdmin(String id) async {
    if (state is! BusinessAdminLoaded) return;
    final currentState = state as BusinessAdminLoaded;
    final originalAdmins = List.of(currentState.allAdmins);

    // Optimistic Update: Remove the admin from the list
    final updatedAdmins = currentState.allAdmins.where((admin) => admin.id != id).toList();
    emit(currentState.copyWith(allAdmins: updatedAdmins));

    final result = await repository.softDeleteBusinessAdmin(id);

    result.fold(
      (failure) {
        // Rollback on failure
        emit(currentState.copyWith(allAdmins: originalAdmins));
        // You might want to emit an error state briefly, but emitting the old state is fine for rollback
        // A full robust implementation would dispatch an error message via another channel (e.g. snackbar bloc)
      },
      (_) {}, // Success, keep optimistic state
    );
  }

  Future<void> reactivateBusinessAdmin(String id) async {
    if (state is! BusinessAdminLoaded) return;
    final currentState = state as BusinessAdminLoaded;
    final originalAdmins = List.of(currentState.allAdmins);

    // Optimistic Update: Change status to 'Active'
    final updatedAdmins = currentState.allAdmins.map((admin) {
      if (admin.id == id) {
        return admin.copyWith(status: 'Active');
      }
      return admin;
    }).toList();
    emit(currentState.copyWith(allAdmins: updatedAdmins));

    final result = await repository.reactivateBusinessAdmin(id);

    result.fold(
      (failure) {
        // Rollback on failure
        emit(currentState.copyWith(allAdmins: originalAdmins));
      },
      (_) {
        // Fetch fresh data from server to ensure list is accurate (e.g. restoring soft-deleted user)
        fetchBusinessAdmins(forceRefresh: true);
      }, // Success, fetch fresh data
    );
  }
}
