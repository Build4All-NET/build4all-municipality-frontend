import 'dart:io';

import 'package:baladiyati/features/admin/certificates/data/services/certificate_api_service.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class AdminCertificateCubit extends Cubit<AdminCertificateState> {
  AdminCertificateCubit(this._api) : super(const AdminCertificateState());

  final CertificateApiService _api;

  Future<void> loadCertificates() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final certs = await _api.getAllCertificates();
      emit(state.copyWith(loading: false, certificates: certs));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> signCertificate(int requestId) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    try {
      await _api.signCertificate(requestId);
      emit(state.copyWith(actionLoading: false, success: 'SIGNED'));
      await loadCertificates();
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: e.toString()));
    }
  }

  Future<void> unsignCertificate(int requestId) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    try {
      await _api.unsignCertificate(requestId);
      emit(state.copyWith(actionLoading: false, success: 'UNSIGNED'));
      await loadCertificates();
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: e.toString()));
    }
  }

  Future<void> downloadAndOpenCertificate(
    int certificateId,
    String fileName,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true));
    try {
      final bytes = await _api.downloadCertificate(certificateId);

      Directory dir;
      try {
        dir = (await getExternalStorageDirectory())!;
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }

      final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes);

      emit(state.copyWith(actionLoading: false));
      await OpenFilex.open(file.path);
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: e.toString()));
    }
  }
}
