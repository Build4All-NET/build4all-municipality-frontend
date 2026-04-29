import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/features/auth/data/models/auth_response_model.dart';
import 'package:dio/dio.dart';

class ApiAuthMunicipalityService {
    final Dio _dio;

  ApiAuthMunicipalityService(this._dio);

Future<AuthResponseModel?> register({
  required String email,
  required String password,
  required String fullName,
  required String phone,
  required String role,
  required int municipalityId,
  required int ownerProjectLinkId,
  required int ownerProjectId,
}) async {
  try {
    final response = await _dio.post(
      '/auth/users/register',
      data: {
        'email': email,
        'passwordHash': password,
        'fullName': fullName,
        'phone': phone,
        'role': role,
        'ownerProjectLinkId': ownerProjectLinkId,
        'ownerProjectId': ownerProjectId,
        'municipality': {'id': municipalityId},
      },
    );
    print("registered success");
   

  } on DioException catch (e) {
  } catch (e) {
    throw AppException('Failed to register user', original: e);
  }
}

}