import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/Get_Request.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final GetAllRequests getRequests;

  RequestBloc(this.getRequests) : super(RequestState.initial()) {
    on<LoadRequests>(_onLoad);
    on<SearchRequests>(_onSearch);
    on<FilterRequests>(_onFilter);
  }

  // ================= LOAD =================
  Future<void> _onLoad(
    LoadRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    try {
      final data = await getRequests();

      final models = data.cast<RequestModel>();

      emit(state.copyWith(
        loading: false,
        allRequests: models,
        visibleRequests: _applyFilters(
          models,
          state.query,
          state.selectedDepartmentId,
          state.selectedStatus,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: errorMessage(e),
      ));
    }
  }

  // ================= SEARCH =================
  void _onSearch(
    SearchRequests event,
    Emitter<RequestState> emit,
  ) {
    emit(state.copyWith(
      query: event.query,
      visibleRequests: _applyFilters(
        state.allRequests,
        event.query,
        state.selectedDepartmentId,
        state.selectedStatus,
      ),
    ));
  }

  // ================= FILTER (backend + frontend fallback) =================
  Future<void> _onFilter(
    FilterRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      selectedDepartmentId: event.departmentId,
      selectedStatus: event.status,
    ));

    try {
      final data = await getRequests(
        departmentId: event.departmentId,
        status: event.status,
      );

      final models = data.cast<RequestModel>();

      emit(state.copyWith(
        loading: false,
        allRequests: models,
        visibleRequests: _applyFilters(
          models,
          state.query,
          event.departmentId,
          event.status,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  // ================= FILTER LOGIC =================
  List<RequestModel> _applyFilters(
    List<RequestModel> requests,
    String query,
    int? departmentId,
    String? status,
  ) {
    var result = requests;

    // department filter
    if (departmentId != null) {
      result = result
          .where((r) => r.serviceId == departmentId)
          .toList();
    }

    // status filter
   

    // search
    final q = query.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            r.addressText.toLowerCase().contains(q) ||
            r.citizenUserId.toString().contains(q);
      }).toList();
    }

    return result;
  }
}