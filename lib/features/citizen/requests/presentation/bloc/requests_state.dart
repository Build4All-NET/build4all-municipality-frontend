// lib/features/citizen/requests/presentation/bloc/requests_state.dart

import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';

enum RequestsStatus {
  initial,
  loading,
  success,
  failure,
}

class RequestsState {
  final RequestsStatus status;
  final List<RequestModel> requests;
  final String? errorMessage;

  const RequestsState({
    this.status = RequestsStatus.initial,
    this.requests = const [],
    this.errorMessage,
  });

  bool get isLoading => status == RequestsStatus.loading;
  bool get hasError => status == RequestsStatus.failure;

  RequestsState copyWith({
    RequestsStatus? status,
    List<RequestModel>? requests,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}