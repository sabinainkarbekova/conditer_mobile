// services/auth_service.dart
import 'dart:convert';
import 'dart:typed_data'; // Добавлено для Uint8List
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8090';
  static const String authUrl = '$baseUrl/api/auth';
  static const String userUrl = '$baseUrl/api/user';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    print('Токен сохранён: $token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print('Токен из SharedPreferences: $token');
    return token;
  }

  // Удалить токен (при выходе из аккаунта)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print('Токен удалён');
  }

  // РЕГИСТРАЦИЯ
  // Теперь принимает email и phoneNumber как опциональные параметры
  Future<Map<String, dynamic>> register(String username, String password, {String? email, String? phoneNumber}) async {
    final body = {
      'username': username,
      'password': password,
    };

    // Добавляем email и phoneNumber в тело запроса, если они не null
    if (email != null) {
      body['email'] = email;
    }
    if (phoneNumber != null) {
      body['phoneNumber'] = phoneNumber;
    }

    final response = await http.post(
      Uri.parse('$authUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return {'success': true, 'token': data['token']};
    } else {
      final errorData = jsonDecode(response.body);
      print('Ошибка регистрации: ${errorData['error']}');
      return {'success': false, 'error': errorData['error']};
    }
  }

  // Войти
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$authUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Токен получен: ${data['token']}');
      await saveToken(data['token']);
      print('Токен сохранён в SharedPreferences');
      return {'success': true, 'token': data['token']};
    } else {
      final errorData = jsonDecode(response.body);
      print('Ошибка входа: ${errorData['error']}');
      return {'success': false, 'error': errorData['error']};
    }
  }

  // Получить профиль
  // Теперь возвращает id, username, email, phoneNumber
  Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$userUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Ответ от /profile: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Ошибка получения профиля: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
      return null;
    }
  }

  // Обновить профиль
  // Принимает новые значения для username, email, phoneNumber
  Future<Map<String, dynamic>?> updateProfile(String token, {String? username, String? email, String? phoneNumber}) async {
    final body = <String, dynamic>{};

    if (username != null) {
      body['username'] = username;
    }
    if (email != null) {
      body['email'] = email;
    }
    if (phoneNumber != null) {
      body['phoneNumber'] = phoneNumber;
    }

    try {
      final response = await http.put(
        Uri.parse('$userUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Ответ от /profile (update): ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Возвращает, например, сообщение об успехе
      } else {
        final errorData = jsonDecode(response.body);
        print('Ошибка обновления профиля: ${errorData['error']}');
        return {'error': errorData['error']};
      }
    } catch (e) {
      print('Ошибка обновления профиля: $e');
      return {'error': e.toString()};
    }
  }

  // Сменить пароль
  Future<Map<String, dynamic>?> changePassword(String token, String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$userUrl/change-password'), // Используем тот же baseUrl и userUrl
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      print('Ответ от /change-password: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Возвращает, например, сообщение об успехе
      } else {
        final errorData = jsonDecode(response.body);
        print('Ошибка смены пароля: ${errorData['error']}');
        return {'error': errorData['error']};
      }
    } catch (e) {
      print('Ошибка смены пароля: $e');
      return {'error': e.toString()};
    }
  }

  // Получить изображение QR-кода
  Future<Uint8List?> getQRCodeImage(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$userUrl/qrcode'), // Используем тот же baseUrl и userUrl
        headers: {
          'Authorization': 'Bearer $token',
          // 'Content-Type': 'image/png', // Этот заголовок не нужен при GET запросе
        },
      );

      print('Ответ от /qrcode: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Возвращаем тело ответа как байты (Uint8List)
        return response.bodyBytes;
      } else {
        print('Ошибка получения QR-кода: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка получения QR-кода: $e');
      return null;
    }
  }
  // services/auth_service.dart
// ... остальные методы ...

  // АДМИН: Получить всех пользователей
  Future<List<Map<String, dynamic>>?> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Ответ от /admin/users: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        // Преобразуем List<dynamic> в List<Map<String, dynamic>>
        return body.cast<Map<String, dynamic>>();
      } else {
        print('Ошибка получения списка пользователей: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка получения списка пользователей: $e');
      return null;
    }
  }

  // АДМИН: Удалить пользователя
  Future<Map<String, dynamic>?> deleteUser(String token, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Ответ от /admin/users/$userId (delete): ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Возвращает, например, сообщение об успехе
      } else {
        final errorData = jsonDecode(response.body);
        print('Ошибка удаления пользователя: ${errorData['error']}');
        return {'error': errorData['error']};
      }
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
      return {'error': e.toString()};
    }
  }

  // АДМИН: Изменить роль пользователя
  Future<Map<String, dynamic>?> changeUserRole(String token, int userId, String newRole) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/users/$userId/role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'role': newRole}),
      );

      print('Ответ от /admin/users/$userId/role (put): ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Возвращает, например, сообщение об успехе
      } else {
        final errorData = jsonDecode(response.body);
        print('Ошибка изменения роли пользователя: ${errorData['error']}');
        return {'error': errorData['error']};
      }
    } catch (e) {
      print('Ошибка изменения роли пользователя: $e');
      return {'error': e.toString()};
    }
  }
}