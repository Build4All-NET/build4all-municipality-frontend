import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Domain/Repository/Employe_Repo.dart';
import 'package:baladiyati/features/admin/staff/data/Model/EmployeModel.dart';
import 'package:baladiyati/features/admin/staff/data/Service/Employe_Api_Service.dart';


class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeApiService api;

  EmployeeRepositoryImpl(this.api);

  @override
  Future<List<Employee>> getEmployees() async {
    return await api.getEmployees();
  }

  @override
  Future<void> createEmployee(Employee employee) async {
    final model = EmployeeModel(
      name: employee.name,
      email: employee.email,
      phone: employee.phone,
      roleId: employee.roleId,
      depId: employee.depId,
    );

    await api.createEmployee(model);
  }
}