class CakeColor {
  final int id;
  final String name;
  final String hexCode;

  CakeColor({
    required this.id,
    required this.name,
    required this.hexCode,
  });

  factory CakeColor.fromJson(Map<String, dynamic> json) {
    return CakeColor(
      id: json['id'] ?? 0, // Защита от null
      name: json['name'] ?? 'Без названия', // Защита от null
      hexCode: json['hexCode'] ?? '#000000', // Защита от null
    );
  }
}