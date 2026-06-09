import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/service_init/presentation/notifier/service_init_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Globally accessible Riverpod 2.x provider for the service-init lifecycle.
final serviceInitNotifierProvider =
    NotifierProvider<ServiceInitNotifier, ServiceInitState>(
  ServiceInitNotifier.new,
);

class ServiceInitNotifier extends Notifier<ServiceInitState> {
  @override
  ServiceInitState build() => ServiceInitState.initial();

  /// Calls [POST /services/init-defaults] on the municipality backend.
  ///
  /// The Bearer JWT is injected automatically by [DioClient] interceptors;
  /// the tenant identity ([municipalityId] / [ownerProjectLinkId]) is parsed
  /// server-side from that token — no explicit request body is required.
  Future<void> initializeDefaultServices() async {
    // ── Concurrency guard ──────────────────────────────────────────────────
    // Silently discard re-entrant calls and post-success re-triggers.
    if (state.status == ServiceInitStatus.loading ||
        state.status == ServiceInitStatus.success) {
      return;
    }

    // ── Background thread safety ───────────────────────────────────────────
    // Defers the entire mutation chain to the microtask queue, preventing any
    // state update from firing while the widget build pipeline is still active.
    await Future.microtask(() async {
      state = state.copyWith(
        status: ServiceInitStatus.loading,
        errorMessage: null,
        data: null,
      );

      try {
        final response = await DioClient.muni.post<Map<String, dynamic>>(
          '/services/init-defaults',
          data: <String, dynamic>{},
        );

        state = state.copyWith(
          status: ServiceInitStatus.success,
          data: response.data,
        );
      } on DioException catch (e) {
        state = state.copyWith(
          status: ServiceInitStatus.error,
          errorMessage: _resolveDioError(e),
        );
      } catch (_) {
        state = state.copyWith(
          status: ServiceInitStatus.error,
          errorMessage: 'An unexpected error occurred. Please try again.',
        );
      }
    });
  }

  // ── Private error resolution ─────────────────────────────────────────────

  String _resolveDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Verify your network and retry.';

      case DioExceptionType.sendTimeout:
        return 'Request could not be transmitted in time. Please retry.';

      case DioExceptionType.receiveTimeout:
        return 'Server response exceeded the timeout threshold. Please retry.';

      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Check your network connection.';

      case DioExceptionType.cancel:
        return 'Request was cancelled before it could complete.';

      case DioExceptionType.badCertificate:
        return 'SSL certificate verification failed. Contact support.';

      case DioExceptionType.badResponse:
        final body = e.response?.data;
        if (body is Map<String, dynamic>) {
          final msg = body['message'];
          if (msg is String && msg.isNotEmpty) return msg;
        }
        return 'Server error (HTTP ${e.response?.statusCode ?? 'unknown'}).';

      case DioExceptionType.unknown:
      default:
        final raw = e.message;
        return (raw != null && raw.isNotEmpty)
            ? raw
            : 'An unknown network error occurred.';
    }
  }
}
