// lib/features/cake/presentation/pages/coating_selection_screen.dart
import 'package:flutter/material.dart';
import '../../../../models/cake_model.dart';
import '../../../../models/coating.dart';
import '../../../../services/api_service.dart';
import 'color_selection.dart';
import '../../../../services/auth_service.dart'; // Импортируем AuthService для проверки токена

class CoatingSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const CoatingSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _CoatingSelectionScreenState createState() => _CoatingSelectionScreenState();
}

class _CoatingSelectionScreenState extends State<CoatingSelectionScreen> {
  List<CoatingModel> _coatings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoadCoatings(); // Проверяем токен и загружаем покрытия
  }

  // Функция для проверки токена и загрузки данных
  Future<void> _checkTokenAndLoadCoatings() async {
    final authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      // Если токена нет, возвращаемся к корню (обычно ProfileScreen)
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    _loadCoatings(); // Если токен есть, загружаем покрытия
  }

  Future<void> _loadCoatings() async {
    try {
      final coatings = await widget.apiService.getCoatings();
      setState(() {
        _coatings = coatings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onCoatingSelected(CoatingModel coating) {
    setState(() {
      widget.cakeModel.selectCoating(coating.id);
    });
  }

  void _onNextPressed() {
    if (widget.cakeModel.selectedCoatingId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ColorSelectionScreen(
            cakeModel: widget.cakeModel,
            apiService: widget.apiService,
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    widget.cakeModel.selectCoating(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    CoatingModel? selectedCoating;
    if (widget.cakeModel.selectedCoatingId != null) {
      try {
        selectedCoating = _coatings.firstWhere(
              (coating) => coating.id == widget.cakeModel.selectedCoatingId!,
        );
      } catch (e) {
        selectedCoating = null;
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
                  onPressed: _loadCoatings,
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
                  Image.asset(
                    'assets/images/logo2.png', // Укажи путь к логотипу
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3D Cake Preview
              _build3DCakePreview(selectedCoating),

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
                  'Select Coating',
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

              // Основной контент (список покрытий) - будет прокручиваться
              Expanded(
                child: Column(
                  children: [
                    // Coating Selection Cards (прокручиваемый список)
                    SizedBox(
                      height: 122, // Фиксированная высота для списка покрытий
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _coatings.length,
                        itemBuilder: (context, index) {
                          final coating = _coatings[index];
                          final isSelected =
                              widget.cakeModel.selectedCoatingId == coating.id;

                          return _CoatingCard(
                            coating: coating,
                            isSelected: isSelected,
                            onTap: () => _onCoatingSelected(coating),
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
                        onPressed: widget.cakeModel.selectedCoatingId != null
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

  Widget _build3DCakePreview(CoatingModel? selectedCoating) {
    Color layerColor = widget.cakeModel.selectedLayerColor ?? Colors.grey[300]!;
    Color creamColor = widget.cakeModel.selectedCreamColor ?? Colors.white;
    Color fillingColor = widget.cakeModel.selectedFillingColor ?? Colors.transparent;

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

        ],
      ),
    );
  }
}

class _CoatingCard extends StatelessWidget {
  final CoatingModel coating;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoatingCard({
    required this.coating,
    required this.isSelected,
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
                child: Image.asset(
                  'assets/images/layers/layer4.png',
                  fit: BoxFit.contain, // Важно для масштабирования
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coating.name,
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
}