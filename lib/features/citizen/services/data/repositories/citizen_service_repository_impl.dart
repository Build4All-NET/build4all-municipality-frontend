import '../../domain/entities/citizen_service_entity.dart';
import '../../domain/repositories/citizen_service_repository.dart';
import '../services/citizen_service_api_service.dart';

class CitizenServiceRepositoryImpl implements CitizenServiceRepository {
  final CitizenServiceApiService _apiService;

  CitizenServiceRepositoryImpl({
    CitizenServiceApiService? apiService,
  }) : _apiService = apiService ?? CitizenServiceApiService();

  @override
  Future<List<CitizenServiceEntity>> getCitizenServices() {
    return _apiService.getCitizenServices();
  }
}