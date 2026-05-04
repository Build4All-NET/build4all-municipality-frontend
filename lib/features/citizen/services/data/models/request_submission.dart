// lib/features/citizen/services/data/models/request_submission.dart

class RequestSubmission {
  final String title;
  final String description;
  final String? addressText;
  final double? geoLat;
  final double? geoLng;
  final List<String>? attachmentUrls; // raw URLs from upload response

  const RequestSubmission({
    required this.title,
    required this.description,
    this.addressText,
    this.geoLat,
    this.geoLng,
    this.attachmentUrls,
  });

  Map<String, dynamic> toJson() {
    // Convert URLs to AttachementDTO format expected by backend:
    // { "fileName": "uuid_file.jpg", "fileUrl": "/uploads/uuid_file.jpg", "fileType": "image" }
    List<Map<String, dynamic>>? attachments;
    if (attachmentUrls != null && attachmentUrls!.isNotEmpty) {
      attachments = attachmentUrls!.map((url) {
        final fileName = url.split('/').last; // extract filename from URL
        final ext = fileName.split('.').last.toLowerCase();
        final fileType = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)
            ? 'image'
            : ext == 'pdf'
                ? 'pdf'
                : 'document';

        return {
          'fileName': fileName,
          'fileUrl': url,
          'fileType': fileType,
        };
      }).toList();
    }

    return {
      'title': title,
      'description': description,
      if (addressText != null && addressText!.isNotEmpty)
        'addressText': addressText,
      if (geoLat != null) 'geoLat': geoLat,
      if (geoLng != null) 'geoLng': geoLng,
      if (attachments != null) 'attachments': attachments,
    };
  }
}
