class DecorationModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imagePath;

  DecorationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  factory DecorationModel.fromJson(Map<String, dynamic> json) {
    return DecorationModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      imagePath: json['imagePath'],
    );
  }
}

class DecorationPlacement {
  final int decorationId;
  double posX;
  double posY;
  double scale;
  double rotation;

  DecorationPlacement({
    required this.decorationId,
    required this.posX,
    required this.posY,
    required this.scale,
    required this.rotation,
  });

  Map<String, dynamic> toJson() {
    return {
      'decorationId': decorationId,
      'posX': posX,
      'posY': posY,
      'scale': scale,
      'rotation': rotation,
    };
  }
}