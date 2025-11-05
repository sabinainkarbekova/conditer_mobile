// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/auth_service.dart';
import '../../../admin/presentation/screens/admin_screen.dart';
import '../../../auth/screens/auth_screen.dart';
import 'info_screen.dart';
import 'settings_screen.dart';
import 'location_screen.dart';
import 'history_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Загрузка...';
  String _role = 'USER'; // Переменная для роли
  bool _isAuthorized = false;
  bool _isLoading = true; // Добавим состояние загрузки

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Проверяем авторизацию при инициализации
  }

  // Отдельный метод для проверки авторизации
  Future<void> _checkAuthStatus() async {
    try {
      final token = await AuthService().getToken();
      print('Токен в ProfileScreen при инициализации: $token');
      if (token != null) {
        final profileData = await AuthService().getProfile(token);
        print('Данные профиля при инициализации: $profileData');
        if (profileData != null) {
          setState(() {
            _username = profileData['username'] ?? 'Неизвестный';
            _role = profileData['role'] ?? 'USER'; // Получаем роль из профиля
            _isAuthorized = true;
            _isLoading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isAuthorized = false;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isAuthorized = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Ошибка при проверке авторизации: $e');
      if (mounted) {
        setState(() {
          _isAuthorized = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка проверки авторизации'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().removeToken();
    // После логаута сбрасываем состояние и перезагружаем экран
    if (mounted) {
      setState(() {
        _isAuthorized = false;
        _username = 'Загрузка...';
        _role = 'USER'; // Сбрасываем роль
        _isLoading = false; // Убедимся, что не висит загрузка
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized) {
      print('Пользователь не авторизован -> показываем AuthScreen');
      return const AuthScreen();
    }

    print('Пользователь авторизован -> показываем профиль');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo2.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pink[50],
                  child: Icon(Icons.person, color: Colors.black, size: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  _username, // Отображаем имя
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _role, // Отображаем роль
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _role == 'ADMIN' ? Colors.red : Colors.green, // Красный для админа, зелёный для юзера
                  ),
                ),
                const SizedBox(height: 40),

                _buildProfileItem(
                  icon: Icons.info_outline,
                  title: 'Info',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoScreen()),
                    );
                    // После возврата из InfoScreen - обновляем имя и роль
                    // Важно: не перепроверять токен, а просто перезагрузить имя и роль
                    final token = await AuthService().getToken(); // Проверяем, что токен всё ещё есть
                    if (token != null) {
                      final profileData = await AuthService().getProfile(token);
                      if (profileData != null && mounted) {
                        setState(() {
                          _username = profileData['username'] ?? _username; // Обновляем имя, если оно изменилось на бэкенде
                          _role = profileData['role'] ?? _role; // Обновляем роль, если она изменилась на бэкенде
                        });
                      }
                    } else {
                      // Если токена нет, значит, возможно, произошёл логаут где-то в InfoScreen
                      // Это маловероятно, но на всякий случай обновим статус
                      if (mounted) {
                        setState(() {
                          _isAuthorized = false;
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildProfileItem(
                  icon: Icons.history_outlined,
                  title: 'History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildProfileItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildProfileItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                // Показываем кнопку Admin Panel только админам
                if (_role == 'ADMIN')
                  ...[
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Panel',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                        );
                      },
                    ),
                  ],
                // Log out
                const SizedBox(height: 20),
                _buildProfileItem(
                  icon: Icons.logout_outlined,
                  title: 'Log out',
                  onTap: _logout,
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
          ],
        ),
      ),
    );
  }
}