import 'package:dio/dio.dart';
import '../../../../core/exceptions.dart';
import '../../../../core/app_logger.dart';
import '../models/revenue_report_request_model.dart';
import '../models/revenue_report_response_model.dart';

abstract class RevenueReportRemoteDataSource {
  Future<RevenueReportResponseModel> generateRevenueReport(
      RevenueReportRequestModel requestModel);
}

class RevenueReportRemoteDataSourceImpl implements RevenueReportRemoteDataSource {
  final Dio dio;

  RevenueReportRemoteDataSourceImpl({required this.dio});

  @override
  Future<RevenueReportResponseModel> generateRevenueReport(
      RevenueReportRequestModel requestModel) async {
    try {
      final response = await dio.post(
        '/api/reports/revenue',
        data: requestModel.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return RevenueReportResponseModel.fromJson(response.data);
      } else {
        throw const ServerException('Lỗi máy chủ khi tạo báo cáo doanh thu');
      }
    } on DioException catch (e) {
      AppLogger.error('Lỗi khi gọi API generateRevenueReport', e);
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      AppLogger.error('Lỗi không xác định khi generateRevenueReport', e);
      throw ServerException(e.toString());
    }
  }
}
