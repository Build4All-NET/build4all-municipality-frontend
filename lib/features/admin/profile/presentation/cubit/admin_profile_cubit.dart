import 'package:baladiyati/core/utils/error_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_profile_entity.dart';
import '../../domain/usecases/get_admin_profile_usecase.dart';

class AdminProfileState {
  final bool isLoading;
  final AdminProfileEntity? profile;
  final String? error;

  const AdminProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  AdminProfileState copyWith({
    bool? isLoading,
    AdminProfileEntity? profile,
    String? error,
    bool clearError = false,
  }) {
    return AdminProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: clearError ? null : error,
    );
  }
}

class AdminProfileCubit extends Cubit<AdminProfileState> {
  final GetAdminProfileUseCase getAdminProfile;

  AdminProfileCubit({
    required this.getAdminProfile,
  }) : super(const AdminProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await getAdminProfile();

      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: errorMessage(e),
        ),
      );
    }
  }
}