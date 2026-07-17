import '../../domain/entities/revenue_report_response.dart';

class RevenueItemModel extends RevenueItem {
  const RevenueItemModel({
    required super.date,
    required super.amount,
  });

  factory RevenueItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueItemModel(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class RevenueReportResponseModel extends RevenueReportResponse {
  const RevenueReportResponseModel({
    required super.grossRevenue,
    required super.items,
  });

  factory RevenueReportResponseModel.fromJson(Map<String, dynamic> json) {
    return RevenueReportResponseModel(
      grossRevenue: (json['grossRevenue'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => RevenueItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
