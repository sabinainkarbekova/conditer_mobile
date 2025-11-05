// lib/features/profile/presentation/screens/info_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart'; // Импортируем AuthService

class InfoScreen extends StatefulWidget { // Меняем на StatefulWidget
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  Map<String, dynamic>? _profileData;
  Uint8List? _qrCodeImage;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndQRCode();
  }

  Future<void> _loadProfileAndQRCode() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        setState(() {
          _error = 'Токен не найден. Пожалуйста, войдите снова.';
          _isLoading = false;
        });
        return;
      }

      // Загружаем профиль
      final profile = await authService.getProfile(token);
      if (profile != null) {
        setState(() {
          _profileData = profile;
        });
      } else {
        setState(() {
          _error = 'Не удалось загрузить профиль.';
        });
      }

      // Загружаем QR-код
      final qrCode = await authService.getQRCodeImage(token);
      if (qrCode != null) {
        setState(() {
          _qrCodeImage = qrCode;
        });
      } else {
        setState(() {
          _error = 'Не удалось загрузить QR-код.';
        });
      }

    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo2.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.pink[50],
                    child: Icon(Icons.person, color: Colors.black, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileData?['username'] ?? 'N/A', // Подставляем имя из бэкенда
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'User',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF967A0),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your discount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '3%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Заменяем статичное изображение на динамический QR-код
                    _qrCodeImage != null
                        ? Image.memory(
                      _qrCodeImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    )
                        : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.qr_code, size: 40, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // УБРАНО: Обновляем логин (username)
              // GestureDetector(
              //   onTap: () {
              //     _showUsernameModal(context);
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              //     decoration: BoxDecoration(
              //       border: Border(
              //         bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
              //       ),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(icon: Icons.person, color: Colors.black, size: 24),
              //         const SizedBox(width: 16),
              //         Expanded(
              //           child: Text(
              //             'Username',
              //             style: TextStyle(
              //               fontFamily: 'Poppins',
              //               fontSize: 18,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ),
              //         Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
              //       ],
              //     ),
              //   ),
              // ),

              // Обновляем телефон из бэкенда
              GestureDetector(
                onTap: () {
                  _showPhoneNumberModal(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Colors.black, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Phone Number', // или можно подставить реальный номер, если он есть
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
                    ],
                  ),
                ),
              ),

              // Добавим поле для Email, если оно есть
              if (_profileData?['email'] != null)
                GestureDetector(
                  onTap: () {
                    _showEmailModal(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Colors.black, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
                      ],
                    ),
                  ),
                ),

              // Пункт "Change Password"
              GestureDetector(
                onTap: () {
                  _showChangePasswordModal(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.black, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 18),
                    ],
                  ),
                ),
              ),


              const Spacer(),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // УБРАНО: void _showUsernameModal(BuildContext context) { ... }

  void _showPhoneNumberModal(BuildContext context) {
    String phoneNumber = _profileData?['phoneNumber'] ?? 'N/A';
    String newPhoneNumber = phoneNumber;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: newPhoneNumber),
                            onChanged: (value) {
                              newPhoneNumber = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter phone number',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.pink[800]),
                          onPressed: () {
                            // Здесь можно добавить логику редактирования
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Обновляем профиль на бэкенде
                      final authService = AuthService();
                      final token = await authService.getToken();
                      if (token != null && newPhoneNumber != phoneNumber) { // Обновляем, только если изменилось
                        final result = await authService.updateProfile(
                          token,
                          phoneNumber: newPhoneNumber.isEmpty ? null : newPhoneNumber,
                        );

                        if (result != null && result['error'] == null) {
                          // Обновляем локальные данные
                          setState(() {
                            _profileData!['phoneNumber'] = newPhoneNumber.isEmpty ? null : newPhoneNumber;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Phone number updated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result?['error'] ?? 'Failed to update phone number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEmailModal(BuildContext context) {
    String email = _profileData?['email'] ?? 'N/A';
    String newEmail = email;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: newEmail),
                            onChanged: (value) {
                              newEmail = value;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter email',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.pink[800]),
                          onPressed: () {
                            // Здесь можно добавить логику редактирования
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Обновляем профиль на бэкенде
                      final authService = AuthService();
                      final token = await authService.getToken();
                      if (token != null && newEmail != email) { // Обновляем, только если изменилось
                        final result = await authService.updateProfile(
                          token,
                          email: newEmail.isEmpty ? null : newEmail,
                        );

                        if (result != null && result['error'] == null) {
                          // Обновляем локальные данные
                          setState(() {
                            _profileData!['email'] = newEmail.isEmpty ? null : newEmail;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Email updated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result?['error'] ?? 'Failed to update email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Новый метод для изменения пароля
  void _showChangePasswordModal(BuildContext context) {
    String oldPassword = '';
    String newPassword = '';
    String confirmNewPassword = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        oldPassword = value;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Old Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        newPassword = value;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'New Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (value) {
                        confirmNewPassword = value;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Confirm New Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (newPassword != confirmNewPassword) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('New passwords do not match.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      // Вызываем метод из AuthService для смены пароля
                      final authService = AuthService();
                      final token = await authService.getToken();
                      if (token != null) {
                        final result = await authService.changePassword(token, oldPassword, newPassword);

                        if (result != null && result['message'] != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          Navigator.pop(context); // Закрываем модальное окно
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result?['error'] ?? 'Failed to change password'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}