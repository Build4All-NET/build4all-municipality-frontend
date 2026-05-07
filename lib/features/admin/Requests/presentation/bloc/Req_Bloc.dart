import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/UpdateRequestStatus.dart';
import 'package:baladiyati/features/admin/Requests/domain/usecases/getAll_Req_Admin.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final GetAllRequestsAdmin getAllRequestsAdmin;
  final UpdateRequestStatus updateRequestStatus;

  RequestBloc({
    required this.getAllRequestsAdmin,
    required this.updateRequestStatus,
  }) : super(RequestState.initial()) {
    on<LoadRequests>(_onLoad);
    on<SearchRequests>(_onSearch);
    on<FilterRequests>(_onFilter);
    on<UpdateRequestStatusRequested>(_onUpdateStatus);
  }

  Future<void> _onLoad(
    LoadRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        selectedDepartmentId: event.departmentId,
        selectedStatus: event.status,
        clearMessages: true,
      ),
    );

    try {
      final data = await getAllRequestsAdmin(
        departmentId: event.departmentId,
        status: event.status,
      );

      final models = data.cast<RequestModel>();

      emit(
        state.copyWith(
          loading: false,
          allRequests: models,
          visibleRequests: _applyFilters(
            models,
            state.query,
            event.departmentId,
            event.status,
          ),
          selectedDepartmentId: event.departmentId,
          selectedStatus: event.status,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          selectedDepartmentId: event.departmentId,
          selectedStatus: event.status,
          error: errorMessage(e),
        ),
      );
    }
  }

  void _onSearch(
    SearchRequests event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        query: event.query,
        selectedDepartmentId: state.selectedDepartmentId,
        selectedStatus: state.selectedStatus,
        visibleRequests: _applyFilters(
          state.allRequests,
          event.query,
          state.selectedDepartmentId,
          state.selectedStatus,
        ),
      ),
    );
  }

  Future<void> _onFilter(
    FilterRequests event,
    Emitter<RequestState> emit,
  ) async {
    add(
      LoadRequests(
        departmentId: event.departmentId,
        status: event.status,
      ),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateRequestStatusRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        updating: true,
        selectedDepartmentId: state.selectedDepartmentId,
        selectedStatus: state.selectedStatus,
        clearMessages: true,
      ),
    );

    try {
      await updateRequestStatus(
        id: event.id,
        status: event.status,
      );

      emit(
        state.copyWith(
          updating: false,
          selectedDepartmentId: state.selectedDepartmentId,
          selectedStatus: state.selectedStatus,
          success: 'Request status updated successfully',
        ),
      );

      add(
        LoadRequests(
          departmentId: state.selectedDepartmentId,
          status: state.selectedStatus,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updating: false,
          selectedDepartmentId: state.selectedDepartmentId,
          selectedStatus: state.selectedStatus,
          error: errorMessage(e),
        ),
      );
    }
  }

  List<RequestModel> _applyFilters(
    List<RequestModel> requests,
    String query,
    int? departmentId,
    String? status,
  ) {
    var result = requests;

    if (departmentId != null) {
      result = result.where((r) => r.serviceId == departmentId).toList();
    }

    if (status != null && status.trim().isNotEmpty) {
      result = result.where((r) => r.status == status).toList();
    }

    final q = query.toLowerCase().trim();

    if (q.isNotEmpty) {
      result = result.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            r.addressText.toLowerCase().contains(q) ||
            r.trackingNumber.toLowerCase().contains(q) ||
            r.status.toLowerCase().contains(q) ||
            r.citizenName.toLowerCase().contains(q) ||
            r.serviceName.toLowerCase().contains(q) ||
            r.citizenUserId.toString().contains(q);
      }).toList();
    }

    return result;
  }
}