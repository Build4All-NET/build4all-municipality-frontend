import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class StaffServiceApi {
  final Dio dio;

  StaffServiceApi(this.dio);

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await dio.get('/api/services');

      final data = response.data;

      if (data is List) {
        return data
            .map((item) => ServiceModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      }

      throw AppException(AppStrings.current.errInvalidResponse);
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppStrings.current.errLoadServices);
    }
  }
}