import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/violations/data/model/ViolationModel.dart';

class ViolationApiService {
  final dio = DioClient.muni;

  /// ✅ CREATE
  Future<void> createViolation(ViolationModel violation) async {
    try {
      final response = await dio.post(
        "/admin/violations/create",
        data: violation.toJson(),
      );

      print("SUCCESS: ${response.data}");
    } catch (e) {
      print("ERROR API: $e");
      rethrow;
    }
  }

  /// ✅ GET ALL
  Future<List<ViolationModel>> getAllViolations() async {
    try {
      final response = await dio.get("/admin/violations/all");

      return (response.data as List)
          .map((e) => ViolationModel.fromJson(e))
          .toList();
    } catch (e) {
      print("ERROR GET: $e");
      rethrow;
    }
  }
}