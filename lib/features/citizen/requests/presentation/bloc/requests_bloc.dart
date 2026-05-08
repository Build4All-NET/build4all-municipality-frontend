// lib/features/citizen/requests/presentation/bloc/requests_bloc.dart

import 'package:baladiyati/features/citizen/services/data/services/request_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'requests_event.dart';
import 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final RequestService _requestService;

  RequestsBloc({
    RequestService? requestService,
  })  : _requestService = requestService ?? RequestService(),
        super(const RequestsState()) {
    on<RequestsLoadRequested>(_onLoad);
    on<RequestsRefreshRequested>(_onRefresh);
  }

  Future<void> _onLoad(
    RequestsLoadRequested event,
    Emitter<RequestsState> emit,
  ) async {
    await _loadRequests(emit);
  }

  Future<void> _onRefresh(
    RequestsRefreshRequested event,
    Emitter<RequestsState> emit,
  ) async {
    await _loadRequests(emit);
  }

  Future<void> _loadRequests(
    Emitter<RequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RequestsStatus.loading,
        clearError: true,
      ),
    );

    try {
      final requests = await _requestService.getMyRequests();

      emit(
        state.copyWith(
          status: RequestsStatus.success,
          requests: requests,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestsStatus.failure,
          errorMessage: error.toString().replaceAll('Exception:', '').trim(),
        ),
      );
    }
  }
}