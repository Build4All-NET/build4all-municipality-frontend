class Department {
  final int id;
  final String name;
  final String description;
  final bool isFixed;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.isFixed,
  });

  Department copyWith({
    int? id,
    String? name,
    String? description,
    bool? isFixed,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isFixed: isFixed ?? this.isFixed,
    );
  }
}