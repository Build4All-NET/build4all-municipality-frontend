import 'package:baladiyati/features/admin/certificates/data/models/certificate_model.dart';

class AdminCertificateState {
  final List<CertificateModel> certificates;
  final bool loading;
  final bool actionLoading;
  final String? error;
  final String? success;

  const AdminCertificateState({
    this.certificates = const [],
    this.loading = false,
    this.actionLoading = false,
    this.error,
    this.success,
  });

  AdminCertificateState copyWith({
    List<CertificateModel>? certificates,
    bool? loading,
    bool? actionLoading,
    String? error,
    String? success,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminCertificateState(
      certificates: certificates ?? this.certificates,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : (error ?? this.error),
      success: clearSuccess ? null : (success ?? this.success),
    );
  }
}
