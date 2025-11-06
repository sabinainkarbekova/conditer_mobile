// lib/features/cake/presentation/pages/color_selection_screen.dart
import 'package:flutter/material.dart';
import '../../../../models/cake_model.dart';
import '../../../../models/color.dart';
import '../../../../services/api_service.dart';
import 'summary_page.dart';
import '../../../../services/auth_service.dart'; // Импортируем AuthService для проверки токена

class ColorSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const ColorSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _ColorSelectionScreenState createState() => _ColorSelectionScreenState();
}

class _ColorSelectionScreenState extends State<ColorSelectionScreen> {
  List<CakeColor> _colors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoadColors(); // Проверяем токен и загружаем цвета
  }

  // Функция для проверки токена и загрузки данных
  Future<void> _checkTokenAndLoadColors() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      // Если токена нет, возвращаемся к корню (обычно ProfileScreen)
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    _loadColors(); // Если токен есть, загружаем цвета
  }

  Future<void> _loadColors() async {
    try {
      final colors = await widget.apiService.getColors();
      setState(() {
        _colors = colors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onColorSelected(CakeColor color) {
    setState(() {
      widget.cakeModel.selectColor(color.id);
    });
  }

  void _onNextPressed() {
    if (widget.cakeModel.selectedColorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            cakeModel: widget.cakeModel,
            apiService: widget.apiService,
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    widget.cakeModel.selectColor(null);
    Navigator.of(context).pop();
  }

  Color _hexToColor(String hexCode) {
    return Color(int.parse('0xff${hexCode.replaceAll('#', '')}'));
  }

  @override
  Widget build(BuildContext context) {
    CakeColor? selectedColor;
    if (widget.cakeModel.selectedColorId != null) {
      try {
        selectedColor = _colors.firstWhere(
              (color) => color.id == widget.cakeModel.selectedColorId!,
        );
      } catch (e) {
        selectedColor = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // Убираем AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.pink),
          )
              : _error != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $_error',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadColors,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
              : Column(
            children: [
              // Заголовок и кнопка "Back"
              Row(
                children: [
                  const Spacer(),
                  // Добавим логотип, если он есть
                  Image.asset(
                    'assets/images/logo2.png', // Укажи путь к логотипу
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3D Cake Preview
              _build3DCakePreview(selectedColor),

              const SizedBox(height: 40),

              // Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink, // Розовый цвет
                  borderRadius: BorderRadius.circular(15), // Закругления
                ),
                child: const Text(
                  'Select Coating Color',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Основной контент (список цветов) - будет прокручиваться
              Expanded(
                child: Column(
                  children: [
                    // Color Selection Cards (прокручиваемый список)
                    SizedBox(
                      height: 122, // Фиксированная высота для списка цветов
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _colors.length,
                        itemBuilder: (context, index) {
                          final color = _colors[index];
                          final isSelected =
                              widget.cakeModel.selectedColorId == color.id;

                          return _ColorCard(
                            color: color,
                            isSelected: isSelected,
                            colorValue: _hexToColor(color.hexCode),
                            onTap: () => _onColorSelected(color),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20), // Отступ перед кнопками внутри Expanded
                  ],
                ),
              ),

              // Bottom Buttons - *вне* прокручиваемой области, всегда внизу
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onBackPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[50], // Светло-розовый
                          foregroundColor: Colors.pink, // Текст розовый
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Закругления
                            side: BorderSide(
                              color: Colors.pink, // Обводка розовая
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.cakeModel.selectedColorId != null
                            ? _onNextPressed
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink, // Розовый цвет
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Закругления
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Next',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DCakePreview(CakeColor? selectedColor) {
    Color layerColor = widget.cakeModel.selectedLayerColor ?? Colors.grey[300]!;
    Color creamColor = widget.cakeModel.selectedCreamColor ?? Colors.white;
    Color fillingColor = widget.cakeModel.selectedFillingColor ?? Colors.transparent;
    Color coatingColor = selectedColor != null ? _hexToColor(selectedColor.hexCode) : Colors.transparent;

    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer (если выбран)
          if (widget.cakeModel.selectedLayerId != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                layerColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/layers/layer4.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

          // Coating Color (если выбран) - окрашиваем layer4 в цвет покрытия
          if (selectedColor != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                coatingColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/layers/layer4.png', // используем layer4 и окрашиваем в цвет покрытия
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  final CakeColor color;
  final bool isSelected;
  final Color colorValue;
  final VoidCallback onTap;

  const _ColorCard({
    required this.color,
    required this.isSelected,
    required this.colorValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? Colors.pink // Розовый цвет бордера
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: colorValue,
                  child: Center(
                    child: Text(
                      color.name,
                      style: TextStyle(
                        color: _getContrastTextColor(colorValue),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              color.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.pink : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getContrastTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}