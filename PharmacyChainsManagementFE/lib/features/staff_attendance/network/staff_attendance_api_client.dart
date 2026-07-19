import 'package:dio/dio.dart';

import '../../../core/network/network_exceptions.dart';
import '../entity/attendance_check_in_request_dto.dart';
import '../entity/attendance_check_out_request_dto.dart';
import '../entity/attendance_record_dto.dart';

class StaffAttendanceApiClient {
  final Dio _dio;

  StaffAttendanceApiClient(this._dio);

  Future<List<AttendanceRecordDto>> fetchAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/staff-attendance',
        queryParameters: {'from': _date(from), 'to': _date(to)},
      );
      final data = _unwrap(response.data);
      return (data as List<dynamic>)
          .map(
            (item) =>
                AttendanceRecordDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AttendanceRecordDto> checkIn(
    AttendanceCheckInRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/staff-attendance/check-in',
        data: request.toJson(),
      );
      return AttendanceRecordDto.fromJson(
        _unwrap(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AttendanceRecordDto> checkOut(
    AttendanceCheckOutRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/staff-attendance/check-out',
        data: request.toJson(),
      );
      return AttendanceRecordDto.fromJson(
        _unwrap(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  dynamic _unwrap(dynamic data) =>
      data is Map<String, dynamic> && data.containsKey('data')
      ? data['data']
      : data;

  AppException _mapError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkTimeoutException();
    }
    if (error.response?.statusCode == 401) {
      return const UnauthorizedException();
    }
    final data = error.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] as String?
        : null;
    return ServerException(message ?? 'Unable to process attendance.');
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
