abstract class RequestEvent {}

class LoadRequests extends RequestEvent {}
class LoadDepartments extends RequestEvent {}

class SearchRequests extends RequestEvent {
  final String query;
  SearchRequests(this.query);
}

class FilterRequests extends RequestEvent {
  final int? departmentId;
  final String? status; // pending / approved / rejected

  FilterRequests({
    this.departmentId,
    this.status,
  });
}