class ViolationModel {
  final String title;
  final String description;
  final String citizenName;
  final double amount;
  final int departmentId;
  final String location;
  final String violationDate;

  ViolationModel({
    required this.title,
    required this.description,
    required this.citizenName,
    required this.amount,
    required this.departmentId,
    required this.location,
    required this.violationDate,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      title: json['title'],
      description: json['description'],
      citizenName: json['citizenName'],
      amount: (json['amount'] as num).toDouble(),
      departmentId: json['departmentId'],
      location: json['location'],
      violationDate: json['violationDate'],
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "citizenName": citizenName,
        "amount": amount,
        "departmentId": departmentId,
        "location": location,
        "violationDate": violationDate,
      };
}