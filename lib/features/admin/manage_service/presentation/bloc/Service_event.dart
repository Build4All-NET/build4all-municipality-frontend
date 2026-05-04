import 'package:baladiyati/features/admin/manage_service/domain/entities/service.dart';

abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {}

class AddServiceEvent extends ServiceEvent {
  final Service service;
  AddServiceEvent(this.service);
}

class UpdateServiceEvent extends ServiceEvent {
  final int id;
  final Service service;

  UpdateServiceEvent(this.id, this.service);
}

class DeleteServiceEvent extends ServiceEvent {
  final int id;
  DeleteServiceEvent(this.id);
}