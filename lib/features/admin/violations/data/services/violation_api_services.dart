import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/violations/data/model/ViolationModel.dart';
import 'package:dio/dio.dart';

class ViolationApiService {
  final Dio dio;

  ViolationApiService({Dio? dio}) : dio = dio ?? DioClient.muni;

  Future<List<ViolationModel>> getAllViolations() async {
    final response = await dio.get('/api/admin/violations/all');

    return _parseViolationList(response.data);
  }

  Future<void> createViolation(ViolationModel violation) async {
    await dio.post(
      '/api/admin/violations/create',
      data: violation.toJson(),
    );
  }

  Future<void> updateViolation(int id, ViolationModel violation) async {
    await dio.put(
      '/api/admin/violations/$id',
      data: violation.toJson(),
    );
  }

  Future<void> deleteViolation(int id) async {
    await dio.delete('/api/admin/violations/$id');
  }

  Future<List<ViolationModel>> getViolationsByCarPlate(String carPlate) async {
    final cleanedCarPlate = carPlate.trim();

    if (cleanedCarPlate.isEmpty) {
      throw Exception('Car plate is required');
    }

    final response = await dio.get(
      '/api/admin/violations/by-car-plate',
      queryParameters: {
        'carPlate': cleanedCarPlate,
      },
    );

    return _parseViolationList(response.data);
  }

  Future<List<ViolationModel>> getViolationsByIdentityNumber(
    String identityNumber,
  ) async {
    final cleanedIdentityNumber = identityNumber.trim();

    if (cleanedIdentityNumber.isEmpty) {
      throw Exception('Identity number is required');
    }

    final response = await dio.get(
      '/api/admin/violations/by-identity-number',
      queryParameters: {
        'identityNumber': cleanedIdentityNumber,
      },
    );

    return _parseViolationList(response.data);
  }

  Future<List<ViolationModel>> getViolationsByName(String name) async {
    final cleanedName = name.trim();

    if (cleanedName.length < 2) {
      throw Exception('Name must contain at least 2 characters');
    }

    final response = await dio.get(
      '/api/admin/violations/by-name',
      queryParameters: {
        'name': cleanedName,
      },
    );

    return _parseViolationList(response.data);
  }

  List<ViolationModel> _parseViolationList(dynamic data) {
    if (data is! List) {
      throw Exception('Invalid violations response');
    }

    return data
        .map((e) => ViolationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}