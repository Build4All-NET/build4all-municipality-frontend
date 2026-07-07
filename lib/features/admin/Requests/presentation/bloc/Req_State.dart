import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';

class RequestState {
  final bool loading;
  final bool updating;
  final String error;
  final String success;

  final bool payUpdating;
  final String payError;
  final int? paidRequestId;

  final List<RequestModel> allRequests;
  final List<RequestModel> visibleRequests;

  final String query;
  final int? selectedDepartmentId;
  final String? selectedStatus;

  const RequestState({
    required this.loading,
    required this.updating,
    required this.error,
    required this.success,
    required this.payUpdating,
    required this.payError,
    required this.paidRequestId,
    required this.allRequests,
    required this.visibleRequests,
    required this.query,
    required this.selectedDepartmentId,
    required this.selectedStatus,
  });

  factory RequestState.initial() {
    return const RequestState(
      loading: false,
      updating: false,
      error: '',
      success: '',
      payUpdating: false,
      payError: '',
      paidRequestId: null,
      allRequests: [],
      visibleRequests: [],
      query: '',
      selectedDepartmentId: null,
      selectedStatus: null,
    );
  }

  RequestState copyWith({
    bool? loading,
    bool? updating,
    String? error,
    String? success,
    bool? payUpdating,
    String? payError,
    int? paidRequestId,
    List<RequestModel>? allRequests,
    List<RequestModel>? visibleRequests,
    String? query,
    int? selectedDepartmentId,
    String? selectedStatus,
    bool clearMessages = false,
    bool clearPayMessages = false,
  }) {
    return RequestState(
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      error: clearMessages ? '' : (error ?? this.error),
      success: clearMessages ? '' : (success ?? this.success),
      payUpdating: payUpdating ?? this.payUpdating,
      payError: clearPayMessages ? '' : (payError ?? this.payError),
      paidRequestId: clearPayMessages ? null : (paidRequestId ?? this.paidRequestId),
      allRequests: allRequests ?? this.allRequests,
      visibleRequests: visibleRequests ?? this.visibleRequests,
      query: query ?? this.query,
      selectedDepartmentId: selectedDepartmentId,
      selectedStatus: selectedStatus,
    );
  }
}