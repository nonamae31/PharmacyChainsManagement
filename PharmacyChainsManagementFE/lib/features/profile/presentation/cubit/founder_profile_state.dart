import 'package:equatable/equatable.dart';
import '../../domain/entities/founder_profile.dart';

abstract class FounderProfileState extends Equatable {
  const FounderProfileState();

  @override
  List<Object?> get props => [];
}

class FounderProfileInitial extends FounderProfileState {}

class FounderProfileLoading extends FounderProfileState {}

class FounderProfileLoaded extends FounderProfileState {
  final FounderProfile profile;

  const FounderProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FounderProfileUpdating extends FounderProfileState {
  final FounderProfile currentProfile;

  const FounderProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class FounderProfileUpdateSuccess extends FounderProfileState {
  final FounderProfile profile;

  const FounderProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FounderProfileError extends FounderProfileState {
  final String message;
  final FounderProfile? lastProfile;

  const FounderProfileError(this.message, {this.lastProfile});

  @override
  List<Object?> get props => [message, lastProfile];
}
