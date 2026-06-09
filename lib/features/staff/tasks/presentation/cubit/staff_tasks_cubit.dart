import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/features/staff/tasks/presentation/cubit/staff_tasks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffTasksCubit extends Cubit<StaffTasksState> {
  final StaffTaskApiService _api;

  StaffTasksCubit(StaffTaskApiService api)
      : _api = api,
        super(const StaffTasksInitial());

  Future<void> loadTasks() async {
    emit(const StaffTasksLoading());
    try {
      final tasks = await _api.searchMyTasks();
      emit(StaffTasksLoaded(tasks));
    } catch (e) {
      emit(StaffTasksError(errorMessage(e)));
    }
  }
}
