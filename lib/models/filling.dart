class FillingModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // путь к картинке начинки
  final String hexCode;  // цвет в формате #RRGGBB

  FillingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.hexCode,
  });

  factory FillingModel.fromJson(Map<String, dynamic> json) {
    return FillingModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',  // если нет — пустая строка
      hexCode: json['hexCode'] ?? '', // если нет — пустая строка
    );
  }
}