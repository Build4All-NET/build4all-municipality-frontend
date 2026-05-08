// lib/features/citizen/requests/data/models/request_model.dart

class RequestModel {
  final String id;
  final String title;
  final String description;
  final String number;
  final String status;
  final String date;
  final String rawCreatedAt;
  final String addressText;
  final String serviceId;
  final String municipalityId;
  final String citizenUserId;

  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.number,
    required this.status,
    required this.date,
    required this.rawCreatedAt,
    required this.addressText,
    required this.serviceId,
    required this.municipalityId,
    required this.citizenUserId,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final rawDate = _string(
      json['createdAt'] ??
          json['created_at'] ??
          json['date'] ??
          json['submittedAt'] ??
          '',
    );

    return RequestModel(
      id: _string(json['id'] ?? json['_id']),
      title: _string(
        json['title'] ??
            json['serviceNameAr'] ??
            json['serviceNameAR'] ??
            json['service_name_ar'] ??
            json['serviceName'] ??
            json['name'],
      ),
      description: _string(json['description']),
      number: _string(
        json['trackingNumber'] ??
            json['tracking_number'] ??
            json['requestNumber'] ??
            json['request_number'] ??
            json['referenceNumber'] ??
            json['reference_number'] ??
            json['number'] ??
            json['code'],
      ),
      status: _normalizeStatus(json['status']),
      date: _formatDate(rawDate),
      rawCreatedAt: rawDate,
      addressText: _string(json['addressText'] ?? json['address_text']),
      serviceId: _string(json['serviceId'] ?? json['service_id']),
      municipalityId: _string(json['municipalityId'] ?? json['municipality_id']),
      citizenUserId: _string(json['citizenUserId'] ?? json['citizen_user_id']),
    );
  }

  String get displayTitle {
    if (title.trim().isNotEmpty) return title;
    return number.trim().isNotEmpty ? number : id;
  }

  String get displayNumber {
    if (number.trim().isNotEmpty) return number;
    return id.trim().isNotEmpty ? '#$id' : '';
  }

  static String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  static String _normalizeStatus(dynamic value) {
    final raw = _string(value).trim().toLowerCase();

    switch (raw) {
      case 'draft':
        return 'draft';
      case 'submitted':
        return 'submitted';
      case 'under_review':
      case 'underreview':
      case 'review':
      case 'in_review':
        return 'under_review';
      case 'waiting_payment':
      case 'waitingpayment':
      case 'payment':
        return 'waiting_payment';
      case 'approved':
        return 'approved';
      case 'in_field':
      case 'infield':
      case 'field':
        return 'in_field';
      case 'delivered':
      case 'completed':
      case 'done':
        return 'delivered';
      case 'rejected':
        return 'rejected';
      case 'cancelled':
      case 'canceled':
        return 'cancelled';
      default:
        return raw.isEmpty ? 'submitted' : raw;
    }
  }

  static String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';

    try {
      final dt = DateTime.parse(raw).toLocal();

      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year.toString()}';
    } catch (_) {
      return raw;
    }
  }
}