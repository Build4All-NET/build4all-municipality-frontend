import 'package:baladiyati/features/citizen/profile/data/repository/profile_repository_impl.dart';
import 'package:baladiyati/features/citizen/profile/domain/repository/profile_repository.dart';
import 'package:baladiyati/features/citizen/profile/domain/usecase/get_profile_usecase.dart';
import 'package:baladiyati/features/citizen/profile/domain/usecase/update_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/profile_api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  ProfileBloc({
    ProfileRepository? repository,
  })  : _getProfile = GetProfileUseCase(
          repository ??
              ProfileRepositoryImpl(
                api: ProfileApiService(),
              ),
        ),
        _updateProfile = UpdateProfileUseCase(
          repository ??
              ProfileRepositoryImpl(
                api: ProfileApiService(),
              ),
        ),
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        isUpdateSuccess: false,
        errorMessage: null,
      ),
    );

    try {
      final profile = await _getProfile();

      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceAll('Exception:', '').trim(),
        ),
      );
    }
  }

  Future<void> _onUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdating: true,
        isUpdateSuccess: false,
        errorMessage: null,
      ),
    );

    try {
      final updated = await _updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        phone: event.phone,
        address: event.address,
        profileImagePath: event.profileImagePath,
        imageRemoved: event.imageRemoved,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          isUpdateSuccess: true,
          profile: updated,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          isUpdateSuccess: false,
          errorMessage: e.toString().replaceAll('Exception:', '').trim(),
        ),
      );
    }
  }
}