import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {}

class AddService extends ServiceEvent {
  final ServiceModel service;
  AddService(this.service);
}

class FilterServices extends ServiceEvent {
  final int? departmentId;
  FilterServices(this.departmentId);
}