class SportCategory {
  final String id;
  final String name;
  final String description;
  final String iconData;

  SportCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconData': iconData,
    };
  }

  // Create from JSON
  factory SportCategory.fromJson(Map<String, dynamic> json) {
    return SportCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconData: json['iconData'],
    );
  }
}