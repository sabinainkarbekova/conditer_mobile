class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool inStock;
  final int categoryId;
  final double rating;
  final List<String> tastes;
  final List<int> ingredientIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.categoryId,
    this.rating = 4.5,
    this.tastes = const [],
    this.ingredientIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int ? (json['price'] as int).toDouble() : json['price']) ?? 0.0,
      imageUrl: json['imageUrl'] ?? 'assets/images/products/placeholder.jpeg',
      inStock: json['in_stock'] ?? true,
      categoryId: json['category_id'] ?? 0,
      rating: (json['rating']?.toDouble() ?? 4.5),
      tastes: List<String>.from(json['tastes'] ?? []),
      ingredientIds: List<int>.from(json['ingredient_ids'] ?? []),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'in_stock': inStock,
      'category_id': categoryId,
      'rating': rating,
      'tastes': tastes,
      'ingredient_ids': ingredientIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}