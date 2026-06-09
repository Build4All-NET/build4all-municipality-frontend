import '../entities/request.dart';

abstract class RequestRepository {
  Future<void> createRequest(RequestEntity request);

  Future<List<RequestEntity>> getRequests({
    int? departmentId,
    String? status,
  });

  Future<RequestEntity> getRequest(int id);

  Future<void> updateRequest(int id, RequestEntity request);

  Future<void> deleteRequest(int id);

  Future<List<RequestEntity>> getAllRequestsAdmin({
    int? departmentId,
    String? status,
  });

  Future<RequestEntity> getRequestAdmin(int id);

  Future<void> updateStatus(int id, String status);
}