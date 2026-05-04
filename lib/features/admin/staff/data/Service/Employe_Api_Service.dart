import 'package:baladiyati/features/admin/staff/data/Model/EmployeModel.dart';
import 'package:dio/dio.dart';

class EmployeeApiService {
  final Dio dio;

  EmployeeApiService(this.dio);

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await dio.get("/api/admin/employees/all");

      final data = response.data as List;

      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Get employees failed: $e");
    }
  }

  Future<void> createEmployee(EmployeeModel employee) async {
    try {
      await dio.post(
        "/api/admin/employees/create",
        data: employee.toJson(),
      );
    } catch (e) {
      throw Exception("Create employee failed: $e");
    }
  }
}