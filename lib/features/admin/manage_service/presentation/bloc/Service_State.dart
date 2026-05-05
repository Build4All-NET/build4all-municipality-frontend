import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

abstract class ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  ServiceLoaded(this.services);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}