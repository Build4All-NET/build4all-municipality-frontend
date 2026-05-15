class ServiceModel {
  final int id;
  final int municipalityId;
  final int departmentId;
  final String? departmentName;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int slaDays;
  final bool requiresInspection;
  final bool hasFees;
  final double feeAmount;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.municipalityId,
    required this.departmentId,
    this.departmentName,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.slaDays,
    required this.requiresInspection,
    required this.hasFees,
    required this.feeAmount,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: _toInt(json['id']),
      municipalityId: _toInt(json['municipalityId'] ?? json['municipality']?['id']),
      departmentId: _toInt(json['departmentId'] ?? json['department']?['id']),
      departmentName: (json['departmentName'] ?? json['department']?['name'])?.toString(),
      nameAr: (json['nameAr'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? '').toString(),
      descriptionAr: (json['descriptionAr'] ?? '').toString(),
      descriptionEn: (json['descriptionEn'] ?? '').toString(),
      slaDays: _toInt(json['slaDays']),
      requiresInspection: _toBool(json['requiresInspection']),
      hasFees: _toBool(json['hasFees']),
      feeAmount: _toDouble(json['feeAmount']),
      isActive: _toBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipalityId': municipalityId,
      'departmentId': departmentId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'slaDays': slaDays,
      'requiresInspection': requiresInspection,
      'hasFees': hasFees,
      'feeAmount': feeAmount,
      'isActive': isActive,
    };
  }

  ServiceModel copyWith({
    int? id,
    int? municipalityId,
    int? departmentId,
    String? departmentName,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    int? slaDays,
    bool? requiresInspection,
    bool? hasFees,
    double? feeAmount,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      municipalityId: municipalityId ?? this.municipalityId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      slaDays: slaDays ?? this.slaDays,
      requiresInspection: requiresInspection ?? this.requiresInspection,
      hasFees: hasFees ?? this.hasFees,
      feeAmount: feeAmount ?? this.feeAmount,
      isActive: isActive ?? this.isActive,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final text = value?.toString().toLowerCase().trim();

    return text == 'true' || text == '1' || text == 'yes';
  }
}
