import 'package:equatable/equatable.dart';
import '../entity/stocktake_request_dto.dart';

sealed class StocktakeEvent extends Equatable {
  const StocktakeEvent();

  @override
  List<Object?> get props => [];
}

final class StocktakeSubmitted extends StocktakeEvent {
  final StocktakeRequestDto request;

  const StocktakeSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
