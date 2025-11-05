// lib/features/profile/presentation/screens/location_screen.dart

import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _mainStSelected = false;
  bool _secondStSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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

              Row(
                children: [
                  Text(
                    'Addresses',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.pink[500],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              _buildAddressCard(
                title: 'Main St.',
                subtitle: 'Bellevue, Washington',
                hours: 'Open 10:00 - 22:00',
                deliveryType: 'Carry out',
                deliveryIcon: Icons.local_dining_outlined,
                isSelected: _mainStSelected,
                onChanged: (bool? value) {
                  if (value == null) return;
                  setState(() {
                    _mainStSelected = value;
                    if (value) _secondStSelected = false;
                  });
                },
              ),
              const SizedBox(height: 20),

              Container(
                height: 1,
                color: Colors.pink[100],
              ),
              const SizedBox(height: 20),

              _buildAddressCard(
                title: 'Second St.',
                subtitle: 'LA, California',
                hours: 'Open 10:00 - 22:00',
                deliveryType: 'Delivery',
                deliveryIcon: Icons.delivery_dining_outlined,
                isSelected: _secondStSelected,
                onChanged: (bool? value) {
                  if (value == null) return;
                  setState(() {
                    _secondStSelected = value;
                    if (value) _mainStSelected = false;
                  });
                },
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
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

                  // Кнопка
                  FloatingActionButton(
                    onPressed: () {
                    },
                    backgroundColor: Colors.pink,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String subtitle,
    required String hours,
    required String deliveryType,
    required IconData deliveryIcon,
    required bool isSelected,
    required void Function(bool?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hours,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deliveryIcon, color: Colors.pink[800], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        deliveryType,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.pink[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
            activeColor: Colors.pink,
            checkColor: Colors.white,
          ),
        ],
      ),
    );
  }
}