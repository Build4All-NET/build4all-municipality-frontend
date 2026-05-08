import '../../domain/entities/admin_profile_entity.dart';

class AdminProfileModel extends AdminProfileEntity {
  const AdminProfileModel({
    required super.adminId,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.businessId,
    required super.notifyItemUpdates,
    required super.notifyUserFeedback,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? asNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      final text = value?.toString().toLowerCase().trim();
      return text == 'true';
    }

    String asString(dynamic value) {
      return value?.toString() ?? '';
    }

    String? asNullableString(dynamic value) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    }

    return AdminProfileModel(
      adminId: asInt(json['adminId']),
      username: asString(json['username']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      email: asString(json['email']),
      phoneNumber: asString(json['phoneNumber']),
      role: asString(json['role']),
      businessId: asNullableInt(json['businessId']),
      notifyItemUpdates: asBool(json['notifyItemUpdates']),
      notifyUserFeedback: asBool(json['notifyUserFeedback']),
      createdAt: asNullableString(json['createdAt']),
      updatedAt: asNullableString(json['updatedAt']),
    );
  }
}