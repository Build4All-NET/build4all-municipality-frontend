// lib/features/citizen/requests/data/models/request_model.dart

class RequestModel {
  final String id;
  final String nameAr;
  final String number;
  final String status;
  final String date;

  const RequestModel({
    required this.id,
    required this.nameAr,
    required this.number,
    required this.status,
    required this.date,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    print('🔥 REQUEST JSON: $json');

    String formattedDate = '';
    try {
      final raw = json['createdAt'] ??
          json['created_at'] ??
          json['date'] ??
          json['submittedAt'] ??
          '';
      if (raw.toString().isNotEmpty) {
        final dt = DateTime.parse(raw.toString());
        formattedDate =
            '${_ar(dt.day.toString().padLeft(2, '0'))}-'
            '${_ar(dt.month.toString().padLeft(2, '0'))}-'
            '${_ar(dt.year.toString())}';
      }
    } catch (_) {}

    return RequestModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nameAr: json['serviceNameAr'] ??
          json['serviceNameAR'] ??
          json['service_name_ar'] ??
          json['serviceName'] ??
          json['name'] ??
          json['title'] ??
          '',
      number: json['requestNumber'] ??
          json['request_number'] ??
          json['referenceNumber'] ??
          json['reference_number'] ??
          json['number'] ??
          json['code'] ??
          '',
      status: (json['status'] ?? '').toString().toLowerCase(),
      date: formattedDate,
    );
  }

  static String _ar(String input) {
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    String r = input;
    for (int i = 0; i < en.length; i++) {
      r = r.replaceAll(en[i], ar[i]);
    }
    return r;
  }
}