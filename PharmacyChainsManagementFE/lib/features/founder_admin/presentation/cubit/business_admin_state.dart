import 'package:equatable/equatable.dart';
import '../../domain/entities/business_admin_entity.dart';

abstract class BusinessAdminState extends Equatable {
  const BusinessAdminState();

  @override
  List<Object?> get props => [];
}

class BusinessAdminInitial extends BusinessAdminState {}

class BusinessAdminLoading extends BusinessAdminState {}

enum AdminFilter { all, active, deactivated }

class BusinessAdminLoaded extends BusinessAdminState {
  final List<BusinessAdminEntity> allAdmins;
  final AdminFilter filter;

  const BusinessAdminLoaded({
    required this.allAdmins,
    this.filter = AdminFilter.all,
  });

  List<BusinessAdminEntity> get admins {
    switch (filter) {
      case AdminFilter.active:
        return allAdmins.where((a) => a.status == 'Active').toList();
      case AdminFilter.deactivated:
        return allAdmins.where((a) => a.status != 'Active').toList();
      case AdminFilter.all:
        return allAdmins;
    }
  }

  BusinessAdminLoaded copyWith({
    List<BusinessAdminEntity>? allAdmins,
    AdminFilter? filter,
  }) {
    return BusinessAdminLoaded(
      allAdmins: allAdmins ?? this.allAdmins,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [allAdmins, filter];
}

class BusinessAdminError extends BusinessAdminState {
  final String message;

  const BusinessAdminError({required this.message});

  @override
  List<Object?> get props => [message];
}
