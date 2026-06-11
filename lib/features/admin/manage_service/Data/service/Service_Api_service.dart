import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:dio/dio.dart';

class ServiceApiService {
  final Dio dio;

  ServiceApiService(this.dio);

  /// Seed default services for this municipality tenant.
  /// Idempotent — safe to call on every dashboard open.
  Future<void> initDefaults() async {
    try {
      await dio.post('/api/admin/services/init-defaults');
    } catch (_) {
      // Silent — never block the dashboard if seed fails
    }
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final res = await dio.get('/api/admin/services');

      final data = res.data;

      if (data is List) {
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }

      throw const AppException('Invalid services response format');
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load services: $e');
    }
  }

  Future<void> create(ServiceModel model) async {
    try {
      await dio.post(
        '/api/admin/services',
        data: model.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to create service: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await dio.delete('/api/admin/services/$id');
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to delete service: $e');
    }
  }

  Future<void> update(int id, ServiceModel model) async {
    try {
      await dio.put(
        '/api/admin/services/$id',
        data: model.toJson(),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to update service: $e');
    }
  }
}
