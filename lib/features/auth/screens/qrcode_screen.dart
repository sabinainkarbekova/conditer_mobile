// lib/features/auth/presentation/screens/qrcode_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  Uint8List? _qrCodeImage;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQRCode();
  }

  Future<void> _loadQRCode() async {
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

      // Делаем GET-запрос к эндпоинту /api/user/qrcode
      final response = await authService.getQRCodeImage(token);

      if (response != null && response.isNotEmpty) {
        setState(() {
          _qrCodeImage = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Не удалось получить QR-код.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки QR-кода: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш QR-код'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        )
            : _qrCodeImage != null
            ? Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.memory(
            _qrCodeImage!,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        )
            : const Text('QR-код не загружен'),
      ),
    );
  }
}