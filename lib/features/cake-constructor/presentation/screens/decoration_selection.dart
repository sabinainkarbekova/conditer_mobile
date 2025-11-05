import 'package:flutter/material.dart';
import '../../../../models/cake_model.dart';
import '../../../../models/decoration.dart';
import '../../../../services/api_service.dart';
import '../../../../widgets/cake_preview.dart';
import 'summary_page.dart';

class DecorationSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const DecorationSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _DecorationSelectionScreenState createState() => _DecorationSelectionScreenState();
}

class _DecorationSelectionScreenState extends State<DecorationSelectionScreen> {
  List<DecorationModel> _decorations = [];
  bool _isLoading = true;
  String? _error;
  DecorationModel? _selectedDecoration;

  @override
  void initState() {
    super.initState();
    _loadDecorations();
  }

  Future<void> _loadDecorations() async {
    try {
      final decorations = await widget.apiService.getDecorations();
      setState(() {
        _decorations = decorations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onDecorationSelected(DecorationModel decoration) {
    setState(() {
      _selectedDecoration = decoration;
    });
  }

  void _onAddDecoration() {
    if (_selectedDecoration != null) {
      final placement = DecorationPlacement(
        decorationId: _selectedDecoration!.id,
        posX: 100.0, // начальная позиция
        posY: 100.0,
        scale: 1.0,
        rotation: 0.0,
      );
      widget.cakeModel.addDecoration(placement);
    }
  }

  void _onNextPressed() {
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

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  void _onClearDecorations() {
    widget.cakeModel.clearDecorations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Декор торта'),
        backgroundColor: Colors.pink[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: _onBackPressed,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: $_error'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDecorations,
              child: const Text('Повторить'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Панель управления
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.pink[50],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Выберите украшение:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _decorations.length,
                          itemBuilder: (context, index) {
                            final decoration = _decorations[index];
                            final isSelected = _selectedDecoration?.id == decoration.id;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _onDecorationSelected(decoration),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(color: Colors.pink, width: 3)
                                        : Border.all(color: Colors.grey),
                                  ),
                                  child: Center(
                                    child: Text(
                                      decoration.name[0],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _selectedDecoration != null ? _onAddDecoration : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Добавить'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _onClearDecorations,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.pink),
                      ),
                      child: const Text(
                        'Очистить',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Область для декорирования торта
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.pink[50]!, Colors.purple[50]!],
                ),
              ),
              child: Stack(
                children: [
                  // Торт
                  Center(
                    child: CakePreview(cakeModel: widget.cakeModel),
                  ),

                  // Украшения
                  ...widget.cakeModel.decorations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final placement = entry.value;

                    return Positioned(
                      left: placement.posX,
                      top: placement.posY,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final newPlacement = DecorationPlacement(
                            decorationId: placement.decorationId,
                            posX: placement.posX + details.delta.dx,
                            posY: placement.posY + details.delta.dy,
                            scale: placement.scale,
                            rotation: placement.rotation,
                          );
                          widget.cakeModel.updateDecoration(index, newPlacement);
                        },
                        child: Transform.rotate(
                          angle: placement.rotation,
                          child: Transform.scale(
                            scale: placement.scale,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orange, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '🎀',
                                  style: TextStyle(fontSize: 20 * placement.scale),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Кнопки навигации
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onBackPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.pink),
                    ),
                    child: const Text(
                      'Назад',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Готово →',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
}