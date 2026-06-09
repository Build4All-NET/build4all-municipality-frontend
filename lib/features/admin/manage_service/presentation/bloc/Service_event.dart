import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {}

class AddService extends ServiceEvent {
  final ServiceModel service;

  AddService(this.service);
}

class UpdateServiceEvent extends ServiceEvent {
  final int id;
  final ServiceModel service;

  UpdateServiceEvent({
    required this.id,
    required this.service,
  });
}

class DeleteServiceEvent extends ServiceEvent {
  final int id;

  DeleteServiceEvent(this.id);
}

class SearchServices extends ServiceEvent {
  final String query;

  SearchServices(this.query);
}

class FilterServices extends ServiceEvent {
  final int? departmentId;

  FilterServices(this.departmentId);
}