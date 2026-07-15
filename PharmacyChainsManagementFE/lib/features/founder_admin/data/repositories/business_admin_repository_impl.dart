import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/business_admin_entity.dart';
import '../../domain/repositories/business_admin_repository.dart';
import '../models/business_admin_model.dart';

class BusinessAdminRepositoryImpl implements BusinessAdminRepository {
  static const String _cacheKey = 'BUSINESS_ADMINS_CACHE';

  BusinessAdminRepositoryImpl();

  @override
  Future<List<BusinessAdminEntity>> getBusinessAdmins({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedData);
          return jsonList.map((json) => BusinessAdminModel.fromJson(json)).toList();
        } catch (e) {
          // Fall through to fetch from API
        }
      }
    }

    // Simulate API fetch delay
    await Future.delayed(const Duration(seconds: 2));

    final mockApiData = [
      {'id': '1', 'name': 'John Doe', 'email': 'john.doe@example.com', 'status': 'Active'},
      {'id': '2', 'name': 'Jane Smith', 'email': 'jane.smith@example.com', 'status': 'Inactive'},
      {'id': '3', 'name': 'Alice Johnson', 'email': 'alice.j@example.com', 'status': 'Active'},
      {'id': '4', 'name': 'Bob Williams', 'email': 'bob.w@example.com', 'status': 'Active'},
      {'id': '5', 'name': 'Charlie Brown', 'email': 'charlie.b@example.com', 'status': 'Inactive'},
    ];

    final models = mockApiData.map((json) => BusinessAdminModel.fromJson(json)).toList();

    // Cache the new data
    prefs.setString(_cacheKey, jsonEncode(models.map((m) => m.toJson()).toList()));

    return models;
  }
}
