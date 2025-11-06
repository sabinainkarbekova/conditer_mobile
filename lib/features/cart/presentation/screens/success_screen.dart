// lib/features/cake/presentation/pages/success_screen.dart
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка успеха (можно заменить на кастомную)
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green, // Зеленый цвет для успеха
              ),
              const SizedBox(height: 40),

              // Заголовок
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green, // Зеленый цвет фона заголовка
                  borderRadius: BorderRadius.circular(15), // Скругленные углы
                ),
                child: const Text(
                  'Success!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 24, // Увеличенный размер шрифта
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Сообщение
              const Text(
                'Your cake has been saved successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 60), // Отступ перед кнопкой

              // Кнопка "Return to Profile"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Заменить SuccessScreen на ProfileScreen
                    Navigator.of(context).pushReplacementNamed('/main');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Розовый цвет кнопки
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Скругленные углы
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Return to Profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}