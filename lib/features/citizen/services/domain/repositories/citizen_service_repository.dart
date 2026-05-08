import '../entities/citizen_service_entity.dart';

abstract class CitizenServiceRepository {
  Future<List<CitizenServiceEntity>> getCitizenServices();
}