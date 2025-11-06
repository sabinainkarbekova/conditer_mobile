import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalog_bloc.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _priceRange = const RangeValues(0, 2000);

  final Map<String, bool> _categories = {
    'All': false,
    'Торты': false,
    'Пирожные': false,
    'Печенье': false,
    'Пироги': false,
  };

  final Map<String, bool> _tastes = {
    'Шоколадный': false,
    'Ванильный': false,
    'Фруктовый': false,
    'Ягодный': false,
    'Кремовый': false,
  };

  final Map<String, bool> _ingredients = {
    'Шоколад': false,
    'Орехи': false,
    'Клубника': false,
    'Сливки': false,
    'Мед': false,
  };

  // Маппинг категорий на ID
  final Map<String, int> _categoryIds = {
    'Торты': 1,
    'Пирожные': 2,
    'Печенье': 3,
    'Пироги': 4,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              'Назад',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Title
                  const Center(
                    child: Text(
                      'Фильтры',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    const Text(
                      'Ценовой диапазон',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceField(
                            'От:',
                            '${_priceRange.start.round()} ₽',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPriceField(
                            'До:',
                            '${_priceRange.end.round()} ₽',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFFFF69B4),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: const Color(0xFFFF69B4),
                        overlayColor: const Color(0xFFFF69B4).withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 2000,
                        divisions: 20,
                        labels: RangeLabels(
                          '${_priceRange.start.round()} ₽',
                          '${_priceRange.end.round()} ₽',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Category
                    const Text(
                      'Категории',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGrid(_categories),

                    const SizedBox(height: 32),

                    // Taste
                    const Text(
                      'Вкусы',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGrid(_tastes),

                    const SizedBox(height: 32),

                    // Ingredients
                    const Text(
                      'Ингредиенты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Поиск ингредиентов...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxGrid(_ingredients),
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _resetFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF69B4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(
                            color: Color(0xFFFF69B4),
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Сбросить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF69B4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Применить',
                        style: TextStyle(
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
    );
  }

  Widget _buildPriceField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxGrid(Map<String, bool> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.entries.map((entry) {
        return GestureDetector(
          onTap: () {
            setState(() {
              // Для "All" категории сбрасываем все остальные
              if (entry.key == 'All' && _categories.containsKey(entry.key)) {
                if (!entry.value) {
                  // Если включаем "All", выключаем все остальные
                  _categories.updateAll((key, value) => key == 'All');
                }
              } else if (_categories.containsKey(entry.key)) {
                // Если выбираем конкретную категорию, выключаем "All"
                _categories['All'] = false;
              }

              items[entry.key] = !entry.value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: entry.value ? const Color(0xFFFF69B4).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: entry.value ? const Color(0xFFFF69B4) : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: entry.value ? const Color(0xFFFF69B4) : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: entry.value ? const Color(0xFFFF69B4) : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: entry.value
                      ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    color: entry.value ? const Color(0xFFFF69B4) : Colors.black87,
                    fontWeight: entry.value ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 2000);
      _categories.updateAll((key, value) => false);
      _tastes.updateAll((key, value) => false);
      _ingredients.updateAll((key, value) => false);
    });
  }

  void _applyFilters(BuildContext context) {
    final Map<String, dynamic> filters = {};

    // Ценовой диапазон
    filters['minPrice'] = _priceRange.start.round();
    filters['maxPrice'] = _priceRange.end.round();

    // Категории
    final selectedCategories = _categories.entries
        .where((entry) => entry.value && entry.key != 'All')
        .map((entry) => entry.key)
        .toList();

    if (selectedCategories.isNotEmpty) {
      // Берем первую выбранную категорию (можно расширить для множественного выбора)
      final categoryName = selectedCategories.first;
      final categoryId = _categoryIds[categoryName];
      if (categoryId != null) {
        filters['categoryId'] = categoryId;
      }
    }

    // Вкусы (если API поддерживает)
    final selectedTastes = _tastes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedTastes.isNotEmpty) {
      filters['tastes'] = selectedTastes.join(',');
    }

    // Ингредиенты (если API поддерживает)
    final selectedIngredients = _ingredients.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedIngredients.isNotEmpty) {
      filters['ingredients'] = selectedIngredients.join(',');
    }

    // Применяем фильтры через BLoC
    context.read<CatalogBloc>().add(FilterProducts(filters));

    // Возвращаемся назад
    Navigator.pop(context);
  }
}