// lib/features/box_design/presentation/screens/boxdesign_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../services/auth_service.dart';

class BoxDesign {
  final int id;
  final String name;
  final String colorCode;
  final int premiumLevel;
  final String imageAssetPath;

  BoxDesign({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.premiumLevel,
    required this.imageAssetPath,
  });

  factory BoxDesign.fromJson(Map<String, dynamic> json) {
    return BoxDesign(
      id: json['id'],
      name: json['name'],
      colorCode: json['colorCode'],
      premiumLevel: json['premiumLevel'],
      imageAssetPath: json['imageAssetPath'],
    );
  }
}

class GreetingCard {
  final int id;
  final String name;
  final String imageAssetPath;
  final String defaultMessage;

  GreetingCard({
    required this.id,
    required this.name,
    required this.imageAssetPath,
    required this.defaultMessage,
  });

  factory GreetingCard.fromJson(Map<String, dynamic> json) {
    return GreetingCard(
      id: json['id'],
      name: json['name'],
      imageAssetPath: json['imageAssetPath'],
      defaultMessage: json['defaultMessage'],
    );
  }
}

class CreateBoxRequest {
  final int boxDesignId;
  final int greetingCardId;
  final String customMessage;

  CreateBoxRequest({
    required this.boxDesignId,
    required this.greetingCardId,
    required this.customMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'boxDesignId': boxDesignId,
      'greetingCardId': greetingCardId,
      'customMessage': customMessage,
    };
  }
}

class BoxDesignScreen extends StatefulWidget {
  const BoxDesignScreen({super.key});

  @override
  State<BoxDesignScreen> createState() => _BoxDesignScreenState();
}

class _BoxDesignScreenState extends State<BoxDesignScreen> {
  final AuthService _authService = AuthService();

  List<BoxDesign> _boxDesigns = [];
  List<GreetingCard> _greetingCards = [];

  int _selectedBoxIndex = -1;
  int _selectedCardIndex = -1;

  final TextEditingController _messageController = TextEditingController();
  int _messageLength = 0;

  bool _isLoading = true;
  String _errorMessage = '';
  String? _authToken;

  static const String baseUrl = 'http://localhost:8090/api';

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _messageLength = _messageController.text.length;
      });
    });
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? token = await _authService.getToken();
      if (token != null) {
        setState(() {
          _authToken = token;
        });
        print('Token loaded in BoxDesignScreen: $_authToken');
        await _loadDataFromBackend();
      } else {
        setState(() {
          _errorMessage = 'Token not found. Please log in.';
          _isLoading = false;
        });
        print('Token not found in SharedPreferences!');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading token: $e';
        _isLoading = false;
      });
      print('Error loading token: $e');
    }
  }

  Future<void> _loadDataFromBackend() async {
    try {
      final designs = await fetchBoxDesigns();
      final cards = await fetchGreetingCards();

      setState(() {
        _boxDesigns = designs;
        _greetingCards = cards;
        _isLoading = false;

        if (_boxDesigns.isNotEmpty) _selectedBoxIndex = 0;
        if (_greetingCards.isNotEmpty) _selectedCardIndex = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading  $e';
        _isLoading = false;
      });
      print('Error loading  $e');
    }
  }

  Future<List<BoxDesign>> fetchBoxDesigns() async {
    final response = await http.get(
      Uri.parse('$baseUrl/boxes/designs'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BoxDesign.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load box designs: ${response.statusCode}');
    }
  }

  Future<List<GreetingCard>> fetchGreetingCards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/boxes/cards'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GreetingCard.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load greeting cards: ${response.statusCode}');
    }
  }

  Future<void> _createBox() async {
    if (_selectedBoxIndex == -1 || _selectedCardIndex == -1 || _authToken == null) {
      if (_authToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please log in again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a box style and card.')),
        );
      }
      return;
    }

    final boxDesignId = _boxDesigns[_selectedBoxIndex].id;
    final cardId = _greetingCards[_selectedCardIndex].id;
    final customMessage = _messageController.text;

    final request = CreateBoxRequest(
      boxDesignId: boxDesignId,
      greetingCardId: cardId,
      customMessage: customMessage,
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/boxes/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken!',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Create box response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Box created successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Choose the box', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _boxDesigns.isEmpty || _greetingCards.isEmpty
            ? const Center(child: Text('No data available.'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- НОВЫЙ БЛОК: Предпросмотр ---
              if (_selectedBoxIndex != -1)
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.6, // Адаптивная высота
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Цвет фона предпросмотра
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // Изображение коробки
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _boxDesigns[_selectedBoxIndex].imageAssetPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('Preview box image error: $error');
                            return Container(
                              color: Colors.red[100],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                      // Изображение открытки в углу
                      if (_selectedCardIndex != -1)
                        Positioned(
                          top: 8, // Отступ сверху
                          right: 8, // Отступ справа
                          child: Container(
                            width: 150, // Ширина контейнера открытки
                            height: 100, // Высота контейнера открытки
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9), // Полупрозрачный фон
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2), // Смещение тени
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                _greetingCards[_selectedCardIndex].imageAssetPath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Preview card image error: $error');
                                  return Container(
                                    color: Colors.red[100],
                                    child: const Icon(Icons.error, size: 16),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              const Text(
                'Select Box Style',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100, // Увеличена высота для размещения названия
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _boxDesigns.length,
                  itemBuilder: (context, index) {
                    final design = _boxDesigns[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBoxIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedBoxIndex == index ? Colors.pink : Colors.grey[300]!,
                              width: _selectedBoxIndex == index ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              // Изображение
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    design.imageAssetPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Thumb error: $error');
                                      return Container(
                                        color: Colors.red[100],
                                        child: const Icon(Icons.error, size: 20),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Название
                              const SizedBox(height: 4),
                              Text(
                                design.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Select Card',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _greetingCards.length,
                  itemBuilder: (context, index) {
                    final card = _greetingCards[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCardIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedCardIndex == index ? Colors.blue : Colors.grey[300]!,
                              width: _selectedCardIndex == index ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              // Изображение
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    card.imageAssetPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Card thumb error: $error');
                                      return Container(
                                        color: Colors.red[100],
                                        child: const Icon(Icons.error, size: 40),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Название
                              const SizedBox(height: 4),
                              Text(
                                card.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Add Personal Message',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your message or wish (up to 200 characters)',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  counterText: _messageLength.toString() + '/200',
                  counterStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createBox,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}