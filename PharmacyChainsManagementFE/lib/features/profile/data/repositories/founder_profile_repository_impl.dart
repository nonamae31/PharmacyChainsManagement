import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/founder_profile.dart';
import '../../domain/repositories/founder_profile_repository.dart';
import '../models/founder_profile_model.dart';

class FounderProfileRepositoryImpl implements FounderProfileRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  static const String _cacheKey = 'founder_profile_cache';

  FounderProfileRepositoryImpl({Dio? dio, FlutterSecureStorage? secureStorage})
      : _dio = dio ?? ApiClient.createDio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<FounderProfile> getProfile(String userId) async {
    try {
      final response = await _dio.get('/api/users/profile');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final profile = FounderProfileModel.fromJson(data);
        await cacheProfile(profile);
        return profile;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      final cached = await getCachedProfile();
      if (cached != null) return cached;
      throw Exception('Failed to load profile. Please try logging in again.');
    }
  }

  @override
  Future<FounderProfile> updateProfile(FounderProfile profile) async {
    try {
      final model = FounderProfileModel.fromEntity(profile);
      // According to requirement: PATCH request
      final response = await _dio.patch(
        '/api/users/profile',
        data: model.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        await cacheProfile(profile);
        return profile;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        '/api/users/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['profilePhotoUri'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> cacheProfile(FounderProfile profile) async {
    final model = FounderProfileModel.fromEntity(profile);
    await _secureStorage.write(key: _cacheKey, value: jsonEncode(model.toJson()));
  }

  @override
  Future<FounderProfile?> getCachedProfile() async {
    final jsonStr = await _secureStorage.read(key: _cacheKey);
    if (jsonStr != null) {
      return FounderProfileModel.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }
}
