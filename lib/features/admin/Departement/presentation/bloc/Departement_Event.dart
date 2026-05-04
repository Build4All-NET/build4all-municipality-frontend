import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

abstract class DepartmentEvent {}

class LoadDepartments extends DepartmentEvent {}

class CreateDepartmentEvent extends DepartmentEvent {
  final Department department;
  CreateDepartmentEvent(this.department);
}

// ✅ DELETE
class DeleteDepartmentEvent extends DepartmentEvent {
  final int id;
  DeleteDepartmentEvent(this.id);
}

// ✅ UPDATE
class UpdateDepartmentEvent extends DepartmentEvent {
  final int id;
  final String name;
  final String description;
  final bool isFixed;

  UpdateDepartmentEvent(
    this.id,
    this.name,
    this.description,
    this.isFixed,
  );
}