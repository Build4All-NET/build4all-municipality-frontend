// lib/features/citizen/services/data/models/request_submission.dart

class RequestSubmission {
  final String title;
  final String description;
  final String? addressText;
  final double? geoLat;
  final double? geoLng;

  const RequestSubmission({
    required this.title,
    required this.description,
    this.addressText,
    this.geoLat,
    this.geoLng,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        if (addressText != null && addressText!.isNotEmpty)
          'addressText': addressText,
        if (geoLat != null) 'geoLat': geoLat,
        if (geoLng != null) 'geoLng': geoLng,
      };
}
