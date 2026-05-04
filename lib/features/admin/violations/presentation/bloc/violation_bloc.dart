import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/DeleteViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/UpdateViolation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViolationBloc extends Bloc<ViolationEvent, ViolationState> {
  final AddViolation addViolation;
  final GetViolations getViolations;
  final UpdateViolation updateViolation;
  final DeleteViolation deleteViolation;

  ViolationBloc({
    required this.addViolation,
    required this.getViolations,
    required this.updateViolation,
    required this.deleteViolation,
  }) : super(ViolationInitial()) {
    on<LoadViolationsEvent>(_onLoad);
    on<CreateViolationEvent>(_onCreate);
    on<UpdateViolationEvent>(_onUpdate);
    on<DeleteViolationEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadViolationsEvent event,
    Emitter<ViolationState> emit,
  ) async {
    emit(ViolationLoading());

    try {
      final list = await getViolations();
      emit(ViolationLoaded(list));
    } catch (e) {
      emit(ViolationError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateViolationEvent event,
    Emitter<ViolationState> emit,
  ) async {
    emit(ViolationLoading());

    try {
      await addViolation(event.violation);
      final list = await getViolations();
      emit(ViolationLoaded(list));
    } catch (e) {
      emit(ViolationError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateViolationEvent event,
    Emitter<ViolationState> emit,
  ) async {
    emit(ViolationLoading());

    try {
      await updateViolation(event.id, event.violation);
      final list = await getViolations();
      emit(ViolationLoaded(list));
    } catch (e) {
      emit(ViolationError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteViolationEvent event,
    Emitter<ViolationState> emit,
  ) async {
    emit(ViolationLoading());

    try {
      await deleteViolation(event.id);
      final list = await getViolations();
      emit(ViolationLoaded(list));
    } catch (e) {
      emit(ViolationError(e.toString()));
    }
  }
}