// lib/features/auth/data/repository/auth_repository_impl.dart
import '../../domain/repository/auth_repository.dart';
import '../services/auth_api_service.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;

  AuthRepositoryImpl({required this.api});

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    // rôle fixé ici
    const role = "CITIZEN";

    final AuthResponseModel response =
        await api.login(email: email, password: password, role: role);

    if (response.token == null || response.token!.isEmpty) {
      throw Exception("Login failed: token missing");
    }
    return response.token;
  }

  @override
  @override
Future<String> register({
  required String email,
  required String password,
  required String fullName,
  //required String phone,
  required String role,
  required int municipalityId,
}) async {
  final  response = await api.register(
    email: email,
    password: password,
    fullName: fullName,
    //phone: phone,
    role: role,
    municipalityId: municipalityId,
  );

  // ✅ Vérifier que token n'est pas null avant de retourner
  if (response.token == null || response.token!.isEmpty) {
    throw Exception("Register failed: token is missing");
  }

  return response.token!; // <-- Le ! est safe car on a vérifié
}

  @override
  Future<void> logout() => api.logout();

  @override
  Future<void> sendVerificationEmail({required String email}) =>
      api.sendVerificationEmail(email: email);

  @override
  Future<void> verifyEmailCode({required String code}) =>
      api.verifyEmailCode(code: code);

  @override
  Future<void> completeProfile({
    required String address,
    required String username,
  }) =>
      api.completeProfile(address: address, username: username);

  @override
  Future<String?> getSavedToken() => api.getSavedToken();
}

extension on Object? {
  get token => null;
}
