// lib/features/citizen/services/data/services/file_upload_service.dart

import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:baladiyati/core/l10n/app_strings.dart';
import 'package:baladiyati/core/utils/picked_file.dart';

class FileUploadService {
  /// Upload multiple files to /api/files/upload
  /// Returns list of file URLs from server
  Future<List<String>> uploadFiles(List<PickedFileData> files) async {
    final baseUrl = ApiClient.baseUrl;
    final token = await AuthTokenStore().getToken();

    final uri = Uri.parse('$baseUrl/api/files/upload');
    final request = http.MultipartRequest('POST', uri);

    // Add auth header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add all files with key "files"
    // Sent from memory (not file paths) so uploads also work on web.
    for (final file in files) {
      request.files.add(file.toHttpMultipart('files'));
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
      throw Exception(AppStrings.current.errUploadFailed);
    }
  }
}
