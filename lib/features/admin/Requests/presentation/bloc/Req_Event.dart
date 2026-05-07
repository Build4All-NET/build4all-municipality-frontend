abstract class RequestEvent {}

class LoadRequests extends RequestEvent {
  final int? departmentId;
  final String? status;

  LoadRequests({
    this.departmentId,
    this.status,
  });
}

class SearchRequests extends RequestEvent {
  final String query;

  SearchRequests(this.query);
}

class FilterRequests extends RequestEvent {
  final int? departmentId;
  final String? status;

  FilterRequests({
    this.departmentId,
    this.status,
  });
}

class UpdateRequestStatusRequested extends RequestEvent {
  final int id;
  final String status;

  UpdateRequestStatusRequested({
    required this.id,
    required this.status,
  });
}