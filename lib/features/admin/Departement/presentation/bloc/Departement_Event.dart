import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

abstract class DepartmentEvent {}

class LoadDepartments extends DepartmentEvent {}

class CreateDepartmentEvent extends DepartmentEvent {
  final Department department;

  CreateDepartmentEvent(this.department);
}