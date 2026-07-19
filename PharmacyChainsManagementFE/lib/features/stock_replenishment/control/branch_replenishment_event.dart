import 'package:equatable/equatable.dart';

import '../entity/stock_replenishment_dto.dart';

sealed class BranchReplenishmentEvent extends Equatable {
  const BranchReplenishmentEvent();

  @override
  List<Object?> get props => [];
}

final class BranchReplenishmentFetchRequested extends BranchReplenishmentEvent {
  const BranchReplenishmentFetchRequested();
}

final class BranchReplenishmentSubmitted extends BranchReplenishmentEvent {
  final CreateStockReplenishmentRequestDto request;

  const BranchReplenishmentSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

final class BranchReplenishmentReceiptConfirmed
    extends BranchReplenishmentEvent {
  final String requestId;

  const BranchReplenishmentReceiptConfirmed(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
