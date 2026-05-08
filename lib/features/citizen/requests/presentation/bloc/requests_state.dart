// lib/features/citizen/requests/presentation/bloc/requests_state.dart

import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';

class RequestsState {
  final bool isLoading;
  final List<RequestModel> requests;
  final String? errorMessage;

  const RequestsState({
    this.isLoading = false,
    this.requests = const [],
    this.errorMessage,
  });

  RequestsState copyWith({
    bool? isLoading,
    List<RequestModel>? requests,
    String? errorMessage,
  }) {
    return RequestsState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
    );
  }
}