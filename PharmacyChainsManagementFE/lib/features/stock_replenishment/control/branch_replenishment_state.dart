import 'package:equatable/equatable.dart';

import '../entity/stock_replenishment_dto.dart';

sealed class BranchReplenishmentState extends Equatable {
  const BranchReplenishmentState();

  @override
  List<Object?> get props => [];
}

final class BranchReplenishmentInitial extends BranchReplenishmentState {
  const BranchReplenishmentInitial();
}

final class BranchReplenishmentLoading extends BranchReplenishmentState {
  const BranchReplenishmentLoading();
}

class BranchReplenishmentLoadSuccess extends BranchReplenishmentState {
  final List<StockReplenishmentOptionDto> options;
  final List<StockReplenishmentRequestDto> requests;
  final bool submitting;
  final String? receivingRequestId;

  const BranchReplenishmentLoadSuccess({
    required this.options,
    required this.requests,
    this.submitting = false,
    this.receivingRequestId,
  });

  @override
  List<Object?> get props => [
    options,
    requests,
    submitting,
    receivingRequestId,
  ];
}

final class BranchReplenishmentSubmitSuccess
    extends BranchReplenishmentLoadSuccess {
  final StockReplenishmentRequestDto createdRequest;

  const BranchReplenishmentSubmitSuccess({
    required super.options,
    required super.requests,
    required this.createdRequest,
  });

  @override
  List<Object?> get props => [...super.props, createdRequest];
}

final class BranchReplenishmentSubmitFailure
    extends BranchReplenishmentLoadSuccess {
  final String message;

  const BranchReplenishmentSubmitFailure({
    required super.options,
    required super.requests,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class BranchReplenishmentReceiptSuccess
    extends BranchReplenishmentLoadSuccess {
  const BranchReplenishmentReceiptSuccess({
    required super.options,
    required super.requests,
  });
}

final class BranchReplenishmentReceiptFailure
    extends BranchReplenishmentLoadSuccess {
  final String message;

  const BranchReplenishmentReceiptFailure({
    required super.options,
    required super.requests,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class BranchReplenishmentLoadFailure extends BranchReplenishmentState {
  final String message;

  const BranchReplenishmentLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
