import 'package:equatable/equatable.dart';

sealed class StocktakeState extends Equatable {
  const StocktakeState();
  
  @override
  List<Object?> get props => [];
}

final class StocktakeInitial extends StocktakeState {}

final class StocktakeLoading extends StocktakeState {}

final class StocktakeSuccess extends StocktakeState {}

final class StocktakeFailure extends StocktakeState {
  final String message;

  const StocktakeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
