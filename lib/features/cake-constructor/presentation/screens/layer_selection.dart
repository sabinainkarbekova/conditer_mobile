import 'package:flutter/material.dart';
import '../../../../models/cake_model.dart';
import '../../../../models/layer.dart';
import '../../../../services/api_service.dart';
import 'cream_selection.dart';

class LayerSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const LayerSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _LayerSelectionScreenState createState() => _LayerSelectionScreenState();
}

class _LayerSelectionScreenState extends State<LayerSelectionScreen> {
  List<Layer> _layers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLayers();
  }

  Future<void> _loadLayers() async {
    try {
      final layers = await widget.apiService.getLayers();
      setState(() {
        _layers = layers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onLayerSelected(Layer layer) {
    widget.cakeModel.selectLayer(
      layer.id,
      color: _hexToColor(layer.hexCode),
    );
  }

  void _onNextPressed() {
    if (widget.cakeModel.selectedLayerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreamSelectionScreen(
            cakeModel: widget.cakeModel,
            apiService: widget.apiService,
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    widget.cakeModel.selectLayer(null);
    Navigator.of(context).pop();
  }

  Color _hexToColor(String hexCode) {
    return Color(int.parse('0xff${hexCode.replaceAll('#', '')}'));
  }

// ... остальной код без изменений до метода build ...

  @override
  Widget build(BuildContext context) {
    Layer? selectedLayer;
    if (widget.cakeModel.selectedLayerId != null) {
      try {
        selectedLayer = _layers.firstWhere(
              (layer) => layer.id == widget.cakeModel.selectedLayerId,
        );
      } catch (e) {
        selectedLayer = null;
      }
    }

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
          'Back', // Обратите внимание: текст "Back", а не "Назад", как в заголовке контейнера ниже
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF4081)),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: $_error'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadLayers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      )
          : Column( // Заменяем на SingleChildScrollView с Column внутри
        children: [
          // Перемещаем кнопки "Назад" и "Далее" наверх, чтобы они были видны при прокрутке
          // или оставляем их внизу, как было. Если они внизу, используем Expanded для основного контента.
          // Вариант 1: Кнопки внизу (как в оригинале, но с SingleChildScrollView)
          Expanded(
            child: SingleChildScrollView( // Добавляем SingleChildScrollView
              child: Column( // Внутри SingleChildScrollView используем Column
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Cake Preview
                  _build3DCakePreview(selectedLayer),

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
                      'Выберите корж',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Layer Selection Cards
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _layers.length,
                      itemBuilder: (context, index) {
                        final layer = _layers[index];
                        final isSelected =
                            widget.cakeModel.selectedLayerId == layer.id;

                        return _LayerCard(
                          layer: layer,
                          isSelected: isSelected,
                          layerColor: _hexToColor(layer.hexCode), // цвет из БД
                          onTap: () => _onLayerSelected(layer),
                        );
                      },
                    ),
                  ),
                  // Добавляем SizedBox, чтобы кнопки не прилипали к карточкам
                  const SizedBox(height: 100), // Высоту можно подогнать
                ],
              ),
            ),
          ),

          // Bottom Buttons - остаются внизу вне прокручиваемой области
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
                    onPressed: _onBackPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF4081),
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
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
                      'Назад',
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
                    onPressed: widget.cakeModel.selectedLayerId != null
                        ? _onNextPressed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      disabledBackgroundColor: Colors.grey[300],
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Далее',
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
    );
  }

// ... остальной код без изменений ...
  Widget _build3DCakePreview(Layer? selectedLayer) {
    Color layerColor = widget.cakeModel.selectedLayerColor ?? (selectedLayer != null ? _hexToColor(selectedLayer.hexCode) : Colors.white);

    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (selectedLayer != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                layerColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/layers/layer1.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          // Можно добавить крем, если есть выбранный
        ],
      ),
    );
  }
}

class _LayerCard extends StatelessWidget {
  final Layer layer;
  final bool isSelected;
  final VoidCallback onTap;
  final Color layerColor; // цвет коржа из БД

  const _LayerCard({
    required this.layer,
    required this.isSelected,
    required this.onTap,
    required this.layerColor,
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
                      ? const Color(0xFFFF4081)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    layerColor,
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/images/layers/layer1.png', // одна картинка для всех слоёв
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              layer.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFFFF4081) : Colors.black87,
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
