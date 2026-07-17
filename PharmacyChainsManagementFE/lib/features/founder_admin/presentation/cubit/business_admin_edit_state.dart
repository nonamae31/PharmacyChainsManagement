import 'package:equatable/equatable.dart';

abstract class BusinessAdminEditState extends Equatable {
  const BusinessAdminEditState();

  @override
  List<Object> get props => [];
}

class BusinessAdminEditInitial extends BusinessAdminEditState {}

class BusinessAdminEditLoading extends BusinessAdminEditState {}

class BusinessAdminEditSuccess extends BusinessAdminEditState {
  final String message;

  const BusinessAdminEditSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class BusinessAdminEditError extends BusinessAdminEditState {
  final String message;

  const BusinessAdminEditError({required this.message});

  @override
  List<Object> get props => [message];
}
