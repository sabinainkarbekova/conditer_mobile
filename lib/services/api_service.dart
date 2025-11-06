import 'dart:convert';
import 'package:http/http.dart' as http;

// ---- Импорты моделей ----
import '../models/product.dart';
import '../models/category.dart';
import '../models/layer.dart';
import '../models/cream.dart';
import '../models/filling.dart';
import '../models/coating.dart';
import '../models/color.dart';
import '../models/decoration.dart';

class ApiService {
  final http.Client client;

  // ---- Базовые URL ----
  static const String shopBaseUrl = 'http://localhost:8090/api';
  static const String constructorBaseUrl = 'http://localhost:8090/api/constructor';

  ApiService({required this.client});

  // ============================================================
  //                     🏪   МАГАЗИН   🏪
  // ============================================================

  /// Получить все продукты
  Future<List<Product>> getProducts() async {
    try {
      final response = await client.get(Uri.parse('$shopBaseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Получить продукты с фильтрацией
  Future<List<Product>> getFilteredProducts(Map<String, dynamic> filters) async {
    try {
      final queryParams = <String, String>{};

      if (filters.containsKey('minPrice')) {
        queryParams['minPrice'] = filters['minPrice'].toString();
      }
      if (filters.containsKey('maxPrice')) {
        queryParams['maxPrice'] = filters['maxPrice'].toString();
      }
      if (filters.containsKey('categoryId')) {
        queryParams['categoryId'] = filters['categoryId'].toString();
      }
      if (filters.containsKey('inStock')) {
        queryParams['inStock'] = filters['inStock'].toString();
      }
      if (filters.containsKey('tastes')) {
        queryParams['taste'] = filters['tastes'].toString();
      }
      if (filters.containsKey('ingredients')) {
        queryParams['ingredient'] = filters['ingredients'].toString();
      }

      final uri = Uri.parse('$shopBaseUrl/products').replace(queryParameters: queryParams);
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load filtered products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Поиск продуктов
  Future<List<Product>> searchProducts(String query) async {
    try {
      final uri = Uri.parse('$shopBaseUrl/products/search')
          .replace(queryParameters: {'query': query});
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  /// Получить список категорий
  Future<List<Category>> getCategories() async {
    try {
      final response = await client.get(Uri.parse('$shopBaseUrl/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Получить доступные фильтры (например, диапазон цен, ингредиенты)
  Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final response =
      await client.get(Uri.parse('$shopBaseUrl/products/filter-options'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load filter options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ============================================================
  //                🎂   КОНСТРУКТОР ТОРТА   🎂
  // ============================================================

  /// Слои
  Future<List<Layer>> getLayers() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/cake-layers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Layer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load layers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load layers: $e');
    }
  }

  /// Кремы
  Future<List<CreamModel>> getCreams() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/cake-creams'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CreamModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load creams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load creams: $e');
    }
  }

  /// Начинки
  Future<List<FillingModel>> getFillings() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/cake-fillings'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FillingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load fillings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load fillings: $e');
    }
  }

  /// Покрытия
  Future<List<CoatingModel>> getCoatings() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/cake-coatings'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CoatingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load coatings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load coatings: $e');
    }
  }

  /// Цвета покрытия
  Future<List<CakeColor>> getColors() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/coating-colors'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CakeColor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load colors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load colors: $e');
    }
  }

  /// Украшения
  Future<List<DecorationModel>> getDecorations() async {
    try {
      final response = await client.get(Uri.parse('$constructorBaseUrl/decorations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DecorationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load decorations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load decorations: $e');
    }
  }

  /// Создать торт (отправка данных конструктора)
  Future<void> createCake(Map<String, dynamic> cakeData) async {
    try {
      final response = await client.post(
        Uri.parse('$constructorBaseUrl/create-cake'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cakeData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to create cake: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create cake: $e');
    }
  }
}
