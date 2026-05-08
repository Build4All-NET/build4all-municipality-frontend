import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';



class AttachmentModel extends Attachment {
  AttachmentModel({
    required String fileName,
    required String fileUrl,
  }) : super(
          fileName: fileName,
          fileUrl: fileUrl,
        );

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fileName": fileName,
      "fileUrl": fileUrl,
    };
  }
}