import 'package:flutter/material.dart';

import '../../../../models/cake_model.dart';
import '../../../../services/api_service.dart';

class SummaryPage extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const SummaryPage({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _isSaving = false;
  String? _saveError;
  String? _saveSuccess;

  Future<void> _saveCake() async {
    if (!widget.cakeModel.isComplete) {
      setState(() {
        _saveError = 'Не все компоненты торта выбраны';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
      _saveSuccess = null;
    });

    try {
      await widget.apiService.createCake(widget.cakeModel.toJson());
      setState(() {
        _isSaving = false;
        _saveSuccess = 'Торт успешно сохранен!';
      });

      // Автоматически вернуться через 2 секунды
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveError = 'Ошибка сохранения: $e';
      });
    }
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  void _onStartOver() {
    widget.cakeModel.clearAll();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildSelectionItem(String title, String? value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFFF4081) : Colors.grey[300],
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  value ?? 'Не выбрано',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? const Color(0xFFFF4081) : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCakePreview() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: _onBackPressed,
        ),
        title: const Text(
          'Back',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 3D Cake Preview
                  _build3DCakePreview(),

                  const SizedBox(height: 40),

                  // Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    color: const Color(0xFFFF4081),
                    child: const Text(
                      'Ваш торт готов!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Детали торта
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildSelectionItem(
                          'Корж',
                          'Выбран',
                          widget.cakeModel.selectedLayerId != null,
                        ),
                        _buildSelectionItem(
                          'Крем',
                          'Выбран',
                          widget.cakeModel.selectedCreamId != null,
                        ),
                        _buildSelectionItem(
                          'Начинка',
                          'Выбрана',
                          widget.cakeModel.selectedFillingId != null,
                        ),
                        _buildSelectionItem(
                          'Покрытие',
                          'Выбрано',
                          widget.cakeModel.selectedCoatingId != null,
                        ),
                        _buildSelectionItem(
                          'Цвет покрытия',
                          'Выбран',
                          widget.cakeModel.selectedColorId != null,
                        ),
                        _buildSelectionItem(
                          'Украшения',
                          '${widget.cakeModel.decorations.length} шт.',
                          widget.cakeModel.decorations.isNotEmpty,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Сообщения об ошибке/успехе
                  if (_saveError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _saveError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_saveSuccess != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _saveSuccess!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCake,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Сохранить торт',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _onStartOver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF4081),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: Color(0xFFFF4081),
                          width: 2,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Собрать новый торт',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}