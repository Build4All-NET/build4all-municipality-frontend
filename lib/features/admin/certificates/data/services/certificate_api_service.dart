import 'dart:typed_data';

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/certificates/data/models/certificate_model.dart';
import 'package:dio/dio.dart';

class CertificateApiService {
  CertificateApiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  final Dio _dio;

  Future<List<CertificateModel>> getAllCertificates() async {
    final response = await _dio.get('/api/certificates');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => CertificateModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> signCertificate(int requestId) async {
    await _dio.put(
      '/api/certificates/request/$requestId/sign',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<void> unsignCertificate(int requestId) async {
    await _dio.put(
      '/api/certificates/request/$requestId/unsign',
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<Uint8List> downloadCertificate(int certificateId) async {
    final response = await _dio.get(
      '/api/certificates/$certificateId/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }
}
