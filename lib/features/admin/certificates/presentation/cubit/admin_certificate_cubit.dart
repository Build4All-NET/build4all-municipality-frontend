
import 'package:baladiyati/features/admin/certificates/data/services/certificate_api_service.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/core/utils/file_store/file_store.dart';

class AdminCertificateCubit extends Cubit<AdminCertificateState> {
  AdminCertificateCubit(this._api) : super(const AdminCertificateState());

  final CertificateApiService _api;

  Future<void> loadCertificates({bool silent = false}) async {
    emit(state.copyWith(
      loading: !silent,
      clearError: true,
      clearSuccess: true,
    ));
    try {
      final certs = await _api.getAllCertificates();
      emit(state.copyWith(loading: false, certificates: certs));
    } catch (e) {
      if (!silent) {
        emit(state.copyWith(loading: false, error: e.toString()));
      } else {
        emit(state.copyWith(loading: false));
      }
    }
  }

  Future<void> signCertificate(int requestId) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    try {
      await _api.signCertificate(requestId);
      emit(state.copyWith(actionLoading: false, success: 'SIGNED'));
      await loadCertificates(silent: true);
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _friendlyError(e)));
    }
  }

  Future<void> unsignCertificate(int requestId) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    try {
      await _api.unsignCertificate(requestId);
      emit(state.copyWith(actionLoading: false, success: 'UNSIGNED'));
      await loadCertificates(silent: true);
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _friendlyError(e)));
    }
  }

  Future<void> downloadAndOpenCertificate(
    int certificateId,
    String fileName,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true));
    try {
      final bytes = await _api.downloadCertificate(certificateId);

      final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final store = const FileStore();
      final handle = await store.save(safeName, bytes);

      emit(state.copyWith(actionLoading: false));
      await store.open(handle);
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _friendlyError(e)));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('DioException') || msg.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('404')) return 'Certificate not found.';
    if (msg.contains('403') || msg.contains('401')) {
      return 'You are not authorised to perform this action.';
    }
    if (msg.contains('500')) return 'Server error. Please try again later.';
    return msg.replaceAll('Exception: ', '');
  }
}
