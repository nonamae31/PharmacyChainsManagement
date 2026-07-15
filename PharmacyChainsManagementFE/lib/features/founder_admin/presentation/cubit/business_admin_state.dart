import 'package:equatable/equatable.dart';
import '../../domain/entities/business_admin_entity.dart';

abstract class BusinessAdminState extends Equatable {
  const BusinessAdminState();

  @override
  List<Object?> get props => [];
}

class BusinessAdminInitial extends BusinessAdminState {}

class BusinessAdminLoading extends BusinessAdminState {}

class BusinessAdminLoaded extends BusinessAdminState {
  final List<BusinessAdminEntity> admins;

  const BusinessAdminLoaded({required this.admins});

  @override
  List<Object?> get props => [admins];
}

class BusinessAdminError extends BusinessAdminState {
  final String message;

  const BusinessAdminError({required this.message});

  @override
  List<Object?> get props => [message];
}
