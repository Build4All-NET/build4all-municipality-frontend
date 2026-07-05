import 'dart:typed_data';
import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/payment_model.dart';

class PaymentApiService {
  final Dio _dio;

  PaymentApiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await _dio.get('/api/payments/user');
      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data['payments'] is List) {
        list = data['payments'] as List;
      } else if (data is Map && data['content'] is List) {
        list = data['content'] as List;
      } else if (data is Map && data['items'] is List) {
        list = data['items'] as List;
      } else {
        list = [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(PaymentModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to load payments');
    }
  }

  Future<Uint8List> downloadReceipt(String requestId) async {
    try {
      final response = await _dio.get(
        '/api/payments/$requestId/receipt',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as Uint8List;
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to download receipt');
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) return (data['message'] ?? data['error'])?.toString();
    return null;
  }
}
