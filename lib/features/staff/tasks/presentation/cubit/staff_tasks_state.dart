import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';

abstract class StaffTasksState {
  const StaffTasksState();
}

class StaffTasksInitial extends StaffTasksState {
  const StaffTasksInitial();
}

class StaffTasksLoading extends StaffTasksState {
  const StaffTasksLoading();
}

class StaffTasksLoaded extends StaffTasksState {
  final List<StaffTaskModel> tasks;
  const StaffTasksLoaded(this.tasks);
}

class StaffTasksError extends StaffTasksState {
  final String message;
  const StaffTasksError(this.message);
}
