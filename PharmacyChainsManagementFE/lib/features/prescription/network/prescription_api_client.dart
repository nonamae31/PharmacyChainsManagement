import 'package:dio/dio.dart';
import '../../../core/exceptions.dart';
import '../entity/prescription_dto.dart';

class PrescriptionApiClient {
  final Dio _dio;
  PrescriptionApiClient(this._dio);
  Future<List<PrescriptionListItemDto>> getPrescriptions() async { try { final response = await _dio.get('/api/v1/prescriptions'); return (response.data as List).map((item) => PrescriptionListItemDto.fromJson(item as Map<String, dynamic>)).toList(); } on DioException catch (error) { throw ServerException(_message(error)); } }
  Future<PrescriptionDto> getPrescription(String prescriptionId) async { try { final response = await _dio.get('/api/v1/prescriptions/$prescriptionId'); return PrescriptionDto.fromJson(response.data as Map<String, dynamic>); } on DioException catch (error) { throw ServerException(_message(error)); } }
  String _message(DioException error) { final data = error.response?.data; if (data is Map<String, dynamic>) return (data['detail'] ?? data['message'] ?? 'Khong the hoan tat yeu cau.').toString(); return 'Khong the ket noi may chu.'; }
}
