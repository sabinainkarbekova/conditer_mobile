// lib/features/payment/presentation/screens/payment_screen.dart

import 'package:flutter/material.dart';
import '../../../profile/presentation/screens/add_card_screen.dart';
import '../../../profile/presentation/screens/cards_list_screen.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/payment_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentIndex = 0; // По умолчанию — Cash on Delivery
  List<PaymentCard> _savedCards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
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

      final cards = await authService.getCards(token);
      if (cards != null) {
        setState(() {
          _savedCards = cards;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Не удалось загрузить карты.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo2.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Text(
                'Payment Method',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              // Способ оплаты: Cash on Delivery
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentIndex = 0;
                  });
                  // Перейти на страницу Cash on Delivery
                  Navigator.pushNamed(context, '/cash_payment');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedPaymentIndex == 0 ? Colors.pink[100] : Colors.pink[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.attach_money_outlined, color: Colors.black, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: _selectedPaymentIndex == 0 ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Способ оплаты: Credit card/Debit card
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentIndex = 1;
                  });
                  // Не переходим, а показываем список карт ниже
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedPaymentIndex == 1 ? Colors.pink[100] : Colors.pink[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card_outlined, color: Colors.black, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Credit card/Debit card',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: _selectedPaymentIndex == 1 ? FontWeight.bold : FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 24),
                    ],
                  ),
                ),
              ),

              // Если выбран способ "Credit card" — показываем список карт
              if (_selectedPaymentIndex == 1)
                ...[
                  const SizedBox(height: 16),
                  // Заголовок "Saved cards"
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Saved cards',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Кнопка "Add Card" (+)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddCardScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Icon(Icons.add, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Add new card',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Список сохранённых карт
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Center(child: Text(_error!))
                  else if (_savedCards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'No saved cards yet.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Чтобы не мешало основному скроллу
                          itemCount: _savedCards.length,
                          itemBuilder: (context, index) {
                            final card = _savedCards[index];
                            final lastFour = card.cardNumber.substring(card.cardNumber.length - 4);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Center(
                                      child: Text(
                                        card.cardType == 'VISA' ? 'V' : 'M',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${card.cardholderName} • $lastFour',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Expires: ${card.expiryDate}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (card.isDefault)
                                    Chip(
                                      label: Text(
                                        'Default',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.blue,
                                    ),
                                  // Кнопка удаления
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Подтверждение удаления
                                      bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Удалить карту?"),
                                          content: Text("Вы уверены, что хотите удалить карту ${card.cardholderName} • $lastFour?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text("Отмена"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text("Удалить"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final authService = AuthService();
                                        final token = await authService.getToken();
                                        if (token == null) return;

                                        final result = await authService.deleteCard(token, card.id);
                                        if (result != null) {
                                          if (result['error'] == null) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Карта удалена'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              // Перезагружаем список карт
                                              _loadSavedCards();
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result['error']),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                ],

              // Пространство до низа
              const Spacer(),

              // Кнопка Back
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: TextButton.icon(
              //     onPressed: () {
              //       Navigator.pop(context); // Закрыть PaymentScreen
              //     },
              //     icon: const Icon(Icons.arrow_back, color: Colors.black),
              //     label: Text(
              //       'Back',
              //       style: TextStyle(
              //         fontFamily: 'Poppins',
              //         fontSize: 16,
              //         fontWeight: FontWeight.w500,
              //         color: Colors.black,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}