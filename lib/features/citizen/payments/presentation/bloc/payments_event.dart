abstract class PaymentsEvent {}

class PaymentsLoadRequested extends PaymentsEvent {}

class PaymentsRefreshRequested extends PaymentsEvent {}

class PaymentsDownloadReceipt extends PaymentsEvent {
  final String requestId;
  PaymentsDownloadReceipt(this.requestId);
}
