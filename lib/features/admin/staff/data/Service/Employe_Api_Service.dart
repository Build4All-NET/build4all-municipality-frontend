import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/staff/data/Model/EmployeModel.dart';
import 'package:dio/dio.dart';

class EmployeeApiService {
  final Dio dio;

  EmployeeApiService(this.dio);

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await dio.get('/api/admin/employees/all');
      final data = response.data;
      if (data is List) {
        return data.map((e) => EmployeeModel.fromJson(e)).toList();
      }
      throw const AppException('Invalid employees response format');
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load employees: $e');
    }
  }

  Future<void> createEmployee(EmployeeModel employee) async {
    try {
      await dio.post('/api/admin/employees/create', data: employee.toJson());
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to create employee: $e');
    }
  }

  Future<void> updateEmployee(int id, EmployeeModel employee) async {
    try {
      await dio.put('/api/admin/employees/$id', data: employee.toJson());
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await dio.delete('/api/admin/employees/$id');
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to delete employee: $e');
    }
  }
}
