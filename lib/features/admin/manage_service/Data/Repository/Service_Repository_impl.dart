import '../../domain/entities/service.dart';
import '../../domain/repository/service_repo.dart';
import '../model/service_model.dart';
import '../service/service_api_service.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceApiService api;

  ServiceRepositoryImpl(this.api);

  @override
  Future<List<Service>> getServices() => api.getServices();

  @override
  Future<void> createService(Service service) {
    final model = ServiceModel(
      municipalityId: service.municipalityId,
      departmentId: service.departmentId,
      nameAr: service.nameAr,
      nameEn: service.nameEn,
      descriptionAr: service.descriptionAr,
      descriptionEn: service.descriptionEn,
      slaDays: service.slaDays,
      requiresInspection: service.requiresInspection,
      hasFees: service.hasFees,
      feeAmount: service.feeAmount,
      isActive: service.isActive,
    );

    return api.createService(model);
  }

  @override
  Future<void> deleteService(int id) => api.deleteService(id);
}