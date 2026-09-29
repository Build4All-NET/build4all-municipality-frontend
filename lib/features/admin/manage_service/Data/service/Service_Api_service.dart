import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class ServiceApiService {
  final Dio dio;

  ServiceApiService(this.dio);

  /// Seed default services for this municipality tenant.
  /// Idempotent — safe to call on every dashboard open.
  Future<void> initDefaults() async {
    try {
      final res = await dio.post('/api/admin/services/init-defaults');
      print('[ServiceApiService] initDefaults success: ${res.statusCode} ${res.data}');
    } on DioException catch (e) {
      print('[ServiceApiService] initDefaults FAILED: status=${e.response?.statusCode} body=${e.response?.data} msg=${e.message}');
    } catch (e) {
      print('[ServiceApiService] initDefaults ERROR: $e');
    }
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final res = await dio.get('/api/admin/services');

      final data = res.data;

      if (data is List) {
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }

      throw AppException(AppStrings.current.errInvalidResponse);
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppStrings.current.errLoadServices);
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
      throw AppException(AppStrings.current.errCreateService);
    }
  }

  Future<void> delete(int id) async {
    try {
      await dio.delete('/api/admin/services/$id');
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppStrings.current.errDeleteService);
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
      throw AppException(AppStrings.current.errUpdateService);
    }
  }
}
