import 'package:baladiyati/features/citizen/services/data/services/ai_service.dart';
import 'package:baladiyati/features/citizen/services/presentation/cubit/ai_service_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiServiceCubit extends Cubit<AiServiceState> {
  AiServiceCubit(this._service) : super(const AiServiceState());

  final AiService _service;

  Future<void> explain(int serviceId) async {
    emit(state.copyWith(status: AiServiceStatus.loading));
    try {
      final reply = await _service.getServiceExplanation(serviceId);
      emit(AiServiceState(status: AiServiceStatus.success, reply: reply));
    } catch (e) {
      emit(AiServiceState(
        status: AiServiceStatus.error,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
