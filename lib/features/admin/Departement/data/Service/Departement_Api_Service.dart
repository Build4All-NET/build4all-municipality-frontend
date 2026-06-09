import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:dio/dio.dart';

class DepartmentApiService {
  final Dio dio;

  DepartmentApiService(this.dio);

 Future<List<DepartmentModel>> getAll() async {
  try {
    final res = await dio.get('/api/admin/departments/all');

    final data = res.data;

    if (data is List) {
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    }

    throw const AppException('Invalid departments response format');
  } on DioException {
    rethrow;
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load departments: $e');
  }
}

  Future<void> add(DepartmentModel model) async {
  await dio.post(
    '/api/admin/departments/create',
    data: model.toJson(),
  );
}

Future<void> update(int id, DepartmentModel model) async {
  await dio.put(
    '/api/admin/departments/$id',
    data: model.toJson(),
  );
}

Future<void> delete(int id) async {
  try {
    await dio.delete('/api/admin/departments/$id');
  } on DioException {
    rethrow;
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to delete department: $e');
  }
}



}