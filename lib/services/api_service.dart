import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/layer.dart';
import '../models/cream.dart';
import '../models/filling.dart';
import '../models/coating.dart';
import '../models/color.dart';
import '../models/decoration.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8090/api/constructor';

  final http.Client client;

  ApiService({required this.client});

  Future<List<Layer>> getLayers() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/cake-layers'));
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

  Future<List<CreamModel>> getCreams() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/cake-creams'));
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

  Future<List<FillingModel>> getFillings() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/cake-fillings'));
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

  Future<List<CoatingModel>> getCoatings() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/cake-coatings'));
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

  Future<List<CakeColor>> getColors() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/coating-colors'));
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

  Future<List<DecorationModel>> getDecorations() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/decorations'));
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

  Future<void> createCake(Map<String, dynamic> cakeData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/create-cake'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cakeData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create cake: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create cake: $e');
    }
  }
}