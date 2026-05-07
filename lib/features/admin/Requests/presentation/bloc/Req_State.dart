import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';


class RequestState {
  final bool loading;
  final String error;

  final List<RequestModel> allRequests;
  final List<RequestModel> visibleRequests;

  final String query;
  final int? selectedDepartmentId;
  final String? selectedStatus;

  RequestState({
    required this.loading,
    required this.error,
    required this.allRequests,
    required this.visibleRequests,
    required this.query,
    required this.selectedDepartmentId,
    required this.selectedStatus,
  });

  factory RequestState.initial() {
    return RequestState(
      loading: false,
      error: '',
      allRequests: [],
      visibleRequests: [],
      query: '',
      selectedDepartmentId: null,
      selectedStatus: null,
    );
  }

  RequestState copyWith({
    bool? loading,
    String? error,
    List<RequestModel>? allRequests,
    List<RequestModel>? visibleRequests,
    String? query,
    int? selectedDepartmentId,
    String? selectedStatus,
    bool clearError = false,
  }) {
    return RequestState(
      loading: loading ?? this.loading,
      error: clearError ? '' : (error ?? this.error),
      allRequests: allRequests ?? this.allRequests,
      visibleRequests: visibleRequests ?? this.visibleRequests,
      query: query ?? this.query,
      selectedDepartmentId:
          selectedDepartmentId ?? this.selectedDepartmentId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}