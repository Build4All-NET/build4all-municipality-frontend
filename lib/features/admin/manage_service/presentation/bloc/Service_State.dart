import 'package:baladiyati/features/admin/manage_service/domain/entities/service.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<Service> services;
  ServiceLoaded(this.services);
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}