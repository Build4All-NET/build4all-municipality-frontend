import 'package:baladiyati/features/admin/Requests/data/Service/Req_Api_Service.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestApiService api;

  RequestRepositoryImpl(this.api);

  @override
  Future<void> createRequest(RequestEntity request) {
    return api.createRequest(request as RequestModel);
  }

  @override
  Future<void> deleteRequest(int id) {
    return api.deleteRequest(id);
  }

  @override
  Future<List<RequestEntity>> getRequests({
    int? departmentId,
    String? status,
  }) {
    return api.getRequests(
      departmentId: departmentId,
      status: status,
    );
  }

  @override
  Future<RequestEntity> getRequest(int id) {
    return api.getRequest(id);
  }

  @override
  Future<void> updateRequest(int id, RequestEntity request) {
    return api.updateRequest(id, request as RequestModel);
  }

  @override
  Future<List<RequestEntity>> getAllRequestsAdmin({
    int? departmentId,
    String? status,
  }) {
    return api.getAllRequestsAdmin(
      departmentId: departmentId,
      status: status,
    );
  }

  @override
  Future<RequestEntity> getRequestAdmin(int id) {
    return api.getRequestAdmin(id);
  }

  @override
  Future<void> updateStatus(int id, String status, {String? message}) {
    return api.updateStatus(id, status, message: message);
  }

  @override
  Future<void> markPaid(int id) {
    return api.markPaid(id);
  }
}