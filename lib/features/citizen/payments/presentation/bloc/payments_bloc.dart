import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:baladiyati/features/citizen/payments/domain/usecases/get_my_payments.dart';
import 'package:baladiyati/features/citizen/payments/domain/usecases/download_receipt.dart';
import 'package:baladiyati/features/citizen/payments/data/repositories/payment_repository_impl.dart';
import 'package:baladiyati/features/citizen/payments/data/services/payment_api_service.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetMyPayments _getMyPayments;
  final DownloadReceipt _downloadReceipt;

  PaymentsBloc({
    GetMyPayments? getMyPayments,
    DownloadReceipt? downloadReceipt,
  })  : _getMyPayments = getMyPayments ??
            GetMyPayments(PaymentRepositoryImpl(PaymentApiService())),
        _downloadReceipt = downloadReceipt ??
            DownloadReceipt(PaymentRepositoryImpl(PaymentApiService())),
        super(const PaymentsState()) {
    on<PaymentsLoadRequested>(_onLoad);
    on<PaymentsRefreshRequested>(_onLoad);
    on<PaymentsDownloadReceipt>(_onDownloadReceipt);
  }

  Future<void> _onLoad(
      PaymentsEvent event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final payments = await _getMyPayments();
      emit(state.copyWith(isLoading: false, payments: payments));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onDownloadReceipt(
      PaymentsDownloadReceipt event, Emitter<PaymentsState> emit) async {
    final id = event.requestId;
    emit(state.copyWith(
      downloadingIds: {...state.downloadingIds, id},
    ));
    try {
      final Uint8List bytes = await _downloadReceipt.call(id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt_$id.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    } finally {
      final updated = Set<String>.from(state.downloadingIds)..remove(id);
      emit(state.copyWith(downloadingIds: updated));
    }
  }
}
