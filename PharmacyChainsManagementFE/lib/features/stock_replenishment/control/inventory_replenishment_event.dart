import 'package:equatable/equatable.dart';

import '../entity/stock_replenishment_dto.dart';

sealed class InventoryReplenishmentEvent extends Equatable {
  const InventoryReplenishmentEvent();

  @override
  List<Object?> get props => [];
}

final class InventoryReplenishmentFetchRequested
    extends InventoryReplenishmentEvent {
  final String status;

  const InventoryReplenishmentFetchRequested({this.status = 'ALL'});

  @override
  List<Object?> get props => [status];
}

final class InventoryReplenishmentStatusUpdated
    extends InventoryReplenishmentEvent {
  final String requestId;
  final UpdateStockReplenishmentStatusDto request;

  const InventoryReplenishmentStatusUpdated({
    required this.requestId,
    required this.request,
  });

  @override
  List<Object?> get props => [requestId, request];
}

final class InventoryReplenishmentDispatchOptionsRequested
    extends InventoryReplenishmentEvent {
  final StockReplenishmentRequestDto request;

  const InventoryReplenishmentDispatchOptionsRequested(this.request);

  @override
  List<Object?> get props => [request];
}

final class InventoryReplenishmentDispatchSubmitted
    extends InventoryReplenishmentEvent {
  final String requestId;
  final DispatchStockReplenishmentDto request;

  const InventoryReplenishmentDispatchSubmitted({
    required this.requestId,
    required this.request,
  });

  @override
  List<Object?> get props => [requestId, request];
}
