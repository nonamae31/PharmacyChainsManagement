part of 'create_admin_cubit.dart';

abstract class CreateAdminState extends Equatable {
  const CreateAdminState();

  @override
  List<Object?> get props => [];
}

class CreateAdminInitial extends CreateAdminState {}

class CreateAdminLoading extends CreateAdminState {}

class CreateAdminSuccess extends CreateAdminState {
  final String message;

  const CreateAdminSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateAdminFailure extends CreateAdminState {
  final String error;

  const CreateAdminFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
