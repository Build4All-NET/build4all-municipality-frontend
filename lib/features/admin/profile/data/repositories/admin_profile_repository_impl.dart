import '../../domain/entities/admin_profile_entity.dart';
import '../../domain/repositories/admin_profile_repository.dart';
import '../models/admin_profile_model.dart';
import '../services/admin_profile_api_service.dart';

class AdminProfileRepositoryImpl implements AdminProfileRepository {
  final AdminProfileApiService api;

  AdminProfileRepositoryImpl({required this.api});

  @override
  Future<AdminProfileEntity> getProfile() async {
    final json = await api.getProfile();
    return AdminProfileModel.fromJson(json);
  }
}