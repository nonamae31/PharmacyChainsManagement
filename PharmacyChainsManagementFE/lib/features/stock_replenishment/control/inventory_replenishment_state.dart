import 'package:equatable/equatable.dart';

import '../entity/stock_replenishment_dto.dart';

sealed class InventoryReplenishmentState extends Equatable {
  const InventoryReplenishmentState();

  @override
  List<Object?> get props => [];
}

final class InventoryReplenishmentInitial extends InventoryReplenishmentState {
  const InventoryReplenishmentInitial();
}

final class InventoryReplenishmentLoading extends InventoryReplenishmentState {
  const InventoryReplenishmentLoading();
}

class InventoryReplenishmentLoadSuccess extends InventoryReplenishmentState {
  final List<StockReplenishmentRequestDto> requests;
  final String status;
  final bool updating;

  const InventoryReplenishmentLoadSuccess({
    required this.requests,
    required this.status,
    this.updating = false,
  });

  @override
  List<Object?> get props => [requests, status, updating];
}

final class InventoryReplenishmentUpdateSuccess
    extends InventoryReplenishmentLoadSuccess {
  const InventoryReplenishmentUpdateSuccess({
    required super.requests,
    required super.status,
  });
}

final class InventoryReplenishmentUpdateFailure
    extends InventoryReplenishmentLoadSuccess {
  final String message;

  const InventoryReplenishmentUpdateFailure({
    required super.requests,
    required super.status,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class InventoryReplenishmentDispatchOptionsSuccess
    extends InventoryReplenishmentLoadSuccess {
  final StockReplenishmentRequestDto request;
  final List<StockReplenishmentSourceDto> sources;

  const InventoryReplenishmentDispatchOptionsSuccess({
    required super.requests,
    required super.status,
    required this.request,
    required this.sources,
  });

  @override
  List<Object?> get props => [...super.props, request, sources];
}

final class InventoryReplenishmentDispatchSuccess
    extends InventoryReplenishmentLoadSuccess {
  const InventoryReplenishmentDispatchSuccess({
    required super.requests,
    required super.status,
  });
}

final class InventoryReplenishmentDispatchFailure
    extends InventoryReplenishmentLoadSuccess {
  final String message;

  const InventoryReplenishmentDispatchFailure({
    required super.requests,
    required super.status,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class InventoryReplenishmentLoadFailure
    extends InventoryReplenishmentState {
  final String message;

  const InventoryReplenishmentLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
