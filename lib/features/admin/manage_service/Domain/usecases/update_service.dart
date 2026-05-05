import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';

class UpdateServiceEvent extends ServiceEvent {
  final int id;
  final ServiceModel service;

  UpdateServiceEvent(this.id, this.service);
}