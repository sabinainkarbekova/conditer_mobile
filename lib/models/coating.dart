class CoatingModel {
  final int id;
  final String name;
  final String description;
  final double price;

  CoatingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory CoatingModel.fromJson(Map<String, dynamic> json) {
    return CoatingModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
    );
  }
}