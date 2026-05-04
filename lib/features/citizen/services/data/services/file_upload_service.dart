// lib/features/citizen/services/data/services/file_upload_service.dart

import 'dart:io';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FileUploadService {
  /// Upload multiple files to /api/files/upload
  /// Returns list of file URLs from server
  Future<List<String>> uploadFiles(List<File> files) async {
    final baseUrl = ApiClient.baseUrl;
    final token = await AuthTokenStore().getToken();

    final uri = Uri.parse('$baseUrl/api/files/upload');
    final request = http.MultipartRequest('POST', uri);

    // Add auth header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add all files with key "files"
    for (final file in files) {
      final fileName = file.path.split('/').last;
      final multipartFile = await http.MultipartFile.fromPath(
        'files',
        file.path,
        filename: fileName,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final fileUrls = List<String>.from(data['fileUrls'] ?? []);
      return fileUrls;
    } else {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }
  }
}
