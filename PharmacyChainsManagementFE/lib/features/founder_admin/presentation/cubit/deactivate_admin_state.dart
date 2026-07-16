import 'package:equatable/equatable.dart';

abstract class DeactivateAdminState extends Equatable {
  const DeactivateAdminState();

  @override
  List<Object?> get props => [];
}

class DeactivateAdminInitial extends DeactivateAdminState {}

class DeactivateAdminLoading extends DeactivateAdminState {}

class DeactivateAdminSuccess extends DeactivateAdminState {
  final String message;

  const DeactivateAdminSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeactivateAdminFailure extends DeactivateAdminState {
  final String error;

  const DeactivateAdminFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
