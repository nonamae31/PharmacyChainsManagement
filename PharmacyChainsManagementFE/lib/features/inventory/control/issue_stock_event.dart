import 'package:equatable/equatable.dart';
import '../entity/issue_stock_request_dto.dart';

sealed class IssueStockEvent extends Equatable {
  const IssueStockEvent();

  @override
  List<Object?> get props => [];
}

final class IssueStockSubmitted extends IssueStockEvent {
  final IssueStockRequestDto request;

  const IssueStockSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
