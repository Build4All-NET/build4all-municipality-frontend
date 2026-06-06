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

  String get requestStatus {
    final s = request?['status']?.toString() ?? '';
    return s.isEmpty ? '-' : s;
  }

  String get citizenName {
    // Try common field names used by various backends
    for (final key in ['citizenName', 'citizenFullName', 'fullName']) {
      final v = request?[key]?.toString() ?? '';
      if (v.isNotEmpty) return v;
    }
    // Nested citizen object
    final citizen = request?['citizen'];
    if (citizen is Map) {
      for (final key in ['fullName', 'name', 'firstName']) {
        final v = citizen[key]?.toString() ?? '';
        if (v.isNotEmpty) return v;
      }
    }
    return '-';
  }

  /// ISO-8601 date string parsed as local DateTime, or null.
  DateTime? get createdAtDate {
    if (createdAt == null) return null;
    return DateTime.tryParse(createdAt!);
  }

  String get formattedDate {
    final dt = createdAtDate;
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
