// lib/features/profile/presentation/screens/add_card_screen.dart
import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/payment_card.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  // final _cvvController = TextEditingController(); // ❌ Удалено
  String _cardType = 'VISA'; // По умолчанию

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Card'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.pink[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите имя держателя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.pink[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                    ),
                    suffixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер карты';
                    }
                    // Убираем пробелы и проверяем длину
                    String cleanValue = value.replaceAll(RegExp(r'\s+'), '');
                    if (cleanValue.length != 16) {
                      return 'Номер карты должен содержать 16 цифр';
                    }
                    // Проверяем, что строка содержит только цифры
                    if (!RegExp(r'^\d{16}$').hasMatch(cleanValue)) {
                      return 'Номер карты должен содержать только цифры';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date (MM/YY)',
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.pink[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.pink, width: 2),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите срок действия';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Формат: MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Expanded(
                    //   child: TextFormField(
                    //     controller: _cvvController, // ❌ Удалено
                    //     decoration: InputDecoration(
                    //       labelText: 'Security Code',
                    //       labelStyle: TextStyle(
                    //         fontFamily: 'Poppins',
                    //         fontSize: 16,
                    //         color: Colors.grey[600],
                    //       ),
                    //       filled: true,
                    //       fillColor: Colors.pink[50],
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         borderSide: BorderSide(color: Colors.pink, width: 2),
                    //       ),
                    //       suffixIcon: Icon(Icons.info_outline, color: Colors.grey[600]),
                    //     ),
                    //     obscureText: true,
                    //     keyboardType: TextInputType.number,
                    //     validator: (value) {
                    //       if (value == null || value.isEmpty) {
                    //         return 'Введите CVV';
                    //       }
                    //       if (value.length != 3) {
                    //         return 'CVV должен содержать 3 цифры';
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _cardType,
                  decoration: InputDecoration(
                    labelText: 'Card Type',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.pink[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  items: ['VISA', 'MASTERCARD', 'AMEX'].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _cardType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final authService = AuthService();
                      final token = await authService.getToken();

                      if (token != null) {
                        final cardData = {
                          'cardholderName': _nameController.text,
                          'cardNumber': _numberController.text,
                          'expiryDate': _expiryController.text,
                          // 'securityCode': _cvvController.text, // ❌ Удалено
                          'cardType': _cardType,
                          'isDefault': true, // Можно сделать по умолчанию
                        };

                        final result = await authService.addCard(token, cardData);

                        if (result != null && result['error'] == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Карта добавлена!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context); // Вернуться назад
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result?['error'] ?? 'Ошибка добавления карты'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Add Card',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}