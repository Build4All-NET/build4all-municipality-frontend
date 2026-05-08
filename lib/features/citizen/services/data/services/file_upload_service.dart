// lib/features/citizen/services/data/services/file_upload_service.dart

import 'dart:io';

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';

class FileUploadService {
  final Dio _muniDio;
  final AuthTokenStore _tokenStore;

  FileUploadService({
    Dio? muniDio,
    AuthTokenStore? tokenStore,
  })  : _muniDio = muniDio ?? DioClient.muni,
        _tokenStore = tokenStore ?? AuthTokenStore();

  Future<String?> _bearerToken() async {
    final token = await _tokenStore.getToken();

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    final clean = token.trim();

    return clean.toLowerCase().startsWith('bearer ')
        ? clean
        : 'Bearer $clean';
  }

  Future<Options?> _authOptions() async {
    final token = await _bearerToken();

    if (token == null) {
      return null;
    }

    return Options(
      headers: {
        'Authorization': token,
      },
    );
  }

  /// POST /api/files/upload
  ///
  /// Backend expected multipart key:
  /// files
  ///
  /// Returns:
  /// List<String> file URLs
  Future<List<String>> uploadFiles(List<File> files) async {
    if (files.isEmpty) {
      return [];
    }

    try {
      final formData = FormData();

      for (final file in files) {
        final fileName = file.path.split(Platform.pathSeparator).last;

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _muniDio.post(
        '/api/files/upload',
        data: formData,
        options: await _authOptions(),
      );

      return _extractFileUrls(response.data);
    } on DioException catch (error) {
      throw _toAppException(
        error,
        fallback: 'Upload failed',
      );
    } catch (error) {
      throw AppException(error.toString());
    }
  }

  List<String> _extractFileUrls(dynamic data) {
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }

    if (data is Map<String, dynamic>) {
      final possibleKeys = [
        'fileUrls',
        'urls',
        'files',
        'data',
        'items',
      ];

      for (final key in possibleKeys) {
        final value = data[key];

        if (value is List) {
          return value.map((item) => item.toString()).toList();
        }
      }

      final singleUrl = data['url'] ?? data['fileUrl'];

      if (singleUrl != null) {
        return [singleUrl.toString()];
      }
    }

    return [];
  }

  AppException _toAppException(
    DioException error, {
    required String fallback,
  }) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return AppException(
        (data['message'] ?? data['error'] ?? fallback).toString(),
      );
    }

    if (data is String && data.trim().isNotEmpty) {
      return AppException(data);
    }

    return AppException(fallback);
  }
}