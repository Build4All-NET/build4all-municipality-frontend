class CertificateModel {
  final int id;
  final String fileName;
  final bool isSigned;
  final String? createdAt;
  final Map<String, dynamic>? request;

  const CertificateModel({
    required this.id,
    required this.fileName,
    required this.isSigned,
    this.createdAt,
    this.request,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int? ?? 0,
      fileName: json['fileName']?.toString() ?? 'certificate.pdf',
      isSigned: json['isSigned'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
      request: json['request'] != null
          ? Map<String, dynamic>.from(json['request'] as Map)
          : null,
    );
  }

  String get requestTitle {
    final t = request?['title']?.toString() ?? '';
    return t.isEmpty ? '-' : t;
  }

  int? get requestId {
    final raw = request?['id'];
    if (raw == null) return null;
    return raw is int ? raw : int.tryParse(raw.toString());
  }

  String get trackingNumber {
    final t = request?['trackingNumber']?.toString() ?? '';
    return t.isEmpty ? '-' : t;
  }
}
