import 'package:equatable/equatable.dart';

class RevenueItem extends Equatable {
  final String date;
  final double amount;

  const RevenueItem({
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [date, amount];
}

class RevenueReportResponse extends Equatable {
  final double grossRevenue;
  final List<RevenueItem> items;

  const RevenueReportResponse({
    required this.grossRevenue,
    required this.items,
  });

  @override
  List<Object?> get props => [grossRevenue, items];
}
