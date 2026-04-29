// lib/features/profile/presentation/bloc/profile_state.dart

import '../../domain/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final bool isUpdating;
  final bool isUpdateSuccess;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.isUpdateSuccess = false,
    this.profile,
    this.errorMessage,
  });

  static const Object _unset = Object();

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isUpdateSuccess,
    ProfileEntity? profile,
    Object? errorMessage = _unset,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUpdateSuccess: isUpdateSuccess ?? this.isUpdateSuccess,
      profile: profile ?? this.profile,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
