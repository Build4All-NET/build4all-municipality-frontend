

import 'package:baladiyati/features/admin/Requests/data/Service/Req_Api_Service.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
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
}) async {
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
  Future<List<RequestEntity>> getAllRequestsAdmin() {
    return api.getAllRequestsAdmin();
  }

  @override
  Future<void> updateStatus(int id, String status) {
    return api.updateStatus(id, status);
  }
}