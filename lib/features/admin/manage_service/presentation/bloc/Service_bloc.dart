import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Create_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Delete_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Get_service.dart';

import 'package:baladiyati/features/admin/manage_service/Domain/usecases/update_service.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_State.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServices getServices;
  final CreateService createService;
  final UpdateService updateService;
  final DeleteService deleteService;

  ServiceBloc({
    required this.getServices,
    required this.createService,
    required this.updateService,
    required this.deleteService,
  }) : super(ServiceState.initial()) {
    on<LoadServices>(_onLoadServices);
    on<AddService>(_onAddService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<DeleteServiceEvent>(_onDeleteService);
    on<SearchServices>(_onSearchServices);
    on<FilterServices>(_onFilterServices);
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final services = await getServices();

      emit(
        state.copyWith(
          loading: false,
          allServices: services,
          visibleServices: _applyFilters(
            services,
            state.query,
            state.selectedDepartmentId,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onAddService(
    AddService event,
    Emitter<ServiceState> emit,
  ) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await createService(event.service);
      final services = await getServices();

      emit(
        state.copyWith(
          actionLoading: false,
          allServices: services,
          visibleServices: _applyFilters(
            services,
            state.query,
            state.selectedDepartmentId,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onUpdateService(
    UpdateServiceEvent event,
    Emitter<ServiceState> emit,
  ) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await updateService(event.id, event.service);
      final services = await getServices();

      emit(
        state.copyWith(
          actionLoading: false,
          allServices: services,
          visibleServices: _applyFilters(
            services,
            state.query,
            state.selectedDepartmentId,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  Future<void> _onDeleteService(
    DeleteServiceEvent event,
    Emitter<ServiceState> emit,
  ) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await deleteService(event.id);
      final services = await getServices();

      emit(
        state.copyWith(
          actionLoading: false,
          allServices: services,
          visibleServices: _applyFilters(
            services,
            state.query,
            state.selectedDepartmentId,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  void _onSearchServices(
    SearchServices event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        query: event.query,
        visibleServices: _applyFilters(
          state.allServices,
          event.query,
          state.selectedDepartmentId,
        ),
      ),
    );
  }

  void _onFilterServices(
    FilterServices event,
    Emitter<ServiceState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDepartmentId: event.departmentId,
        clearSelectedDepartmentId: event.departmentId == null,
        visibleServices: _applyFilters(
          state.allServices,
          state.query,
          event.departmentId,
        ),
      ),
    );
  }

  List<ServiceModel> _applyFilters(
    List<ServiceModel> services,
    String query,
    int? departmentId,
  ) {
    var result = services;

    if (departmentId != null) {
      result = result.where((s) => s.departmentId == departmentId).toList();
    }

    final q = query.trim().toLowerCase();

    if (q.isNotEmpty) {
      result = result.where((s) {
        return s.nameAr.toLowerCase().contains(q) ||
            s.nameEn.toLowerCase().contains(q) ||
            s.descriptionAr.toLowerCase().contains(q) ||
            s.descriptionEn.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}