import 'package:flutter/material.dart';

import '../../../../models/cake_model.dart';
import '../../../../models/filling.dart';
import '../../../../services/api_service.dart';
import 'coating_selection.dart';

class FillingSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const FillingSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _FillingSelectionScreenState createState() => _FillingSelectionScreenState();
}

class _FillingSelectionScreenState extends State<FillingSelectionScreen> {
  List<FillingModel> _fillings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFillings();
  }

  Future<void> _loadFillings() async {
    try {
      final fillings = await widget.apiService.getFillings();
      setState(() {
        _fillings = fillings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFillingSelected(FillingModel filling) {
    setState(() { // ДОБАВЬТЕ ЭТОТ setState
      widget.cakeModel.selectFilling(
        filling.id,
        color: _hexToColor(filling.hexCode),
      );
    });
  }

  void _onNextPressed() {
    if (widget.cakeModel.selectedFillingId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CoatingSelectionScreen(
            cakeModel: widget.cakeModel,
            apiService: widget.apiService,
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    widget.cakeModel.selectFilling(null);
    Navigator.of(context).pop();
  }

  Color _hexToColor(String hexCode) {
    return Color(int.parse('0xff${hexCode.replaceAll('#', '')}'));
  }

  @override
  Widget build(BuildContext context) {
    FillingModel? selectedFilling;
    if (widget.cakeModel.selectedFillingId != null) {
      try {
        selectedFilling = _fillings.firstWhere(
              (filling) => filling.id == widget.cakeModel.selectedFillingId,
        );
      } catch (e) {
        selectedFilling = null;
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
          'Back',
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
              onPressed: _loadFillings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Cake Preview
                _build3DCakePreview(selectedFilling),

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
                    'Выберите начинку',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Filling Selection Cards
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _fillings.length,
                    itemBuilder: (context, index) {
                      final filling = _fillings[index];
                      final isSelected =
                          widget.cakeModel.selectedFillingId == filling.id;

                      return _FillingCard(
                        filling: filling,
                        isSelected: isSelected,
                        fillingColor: _hexToColor(filling.hexCode),
                        onTap: () => _onFillingSelected(filling),
                      );
                    },
                  ),
                ),
              ],
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
                    onPressed: _onBackPressed,
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
                    onPressed: widget.cakeModel.selectedFillingId != null
                        ? _onNextPressed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _build3DCakePreview(FillingModel? selectedFilling) {
    Color layerColor = widget.cakeModel.selectedLayerColor ?? Colors.grey[300]!;
    Color creamColor = widget.cakeModel.selectedCreamColor ?? Colors.white;
    Color fillingColor = widget.cakeModel.selectedFillingColor ??
        (selectedFilling != null ? _hexToColor(selectedFilling.hexCode) : Colors.transparent);

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
                'assets/images/layers/layer2.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

          // Filling (если выбрана)
          if (selectedFilling != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                fillingColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/fillings/filling1.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

          // Cream (если выбран)
          if (widget.cakeModel.selectedCreamId != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                creamColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/creams/cream2.png',
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

class _FillingCard extends StatelessWidget {
  final FillingModel filling;
  final bool isSelected;
  final Color fillingColor;
  final VoidCallback onTap;

  const _FillingCard({
    required this.filling,
    required this.isSelected,
    required this.fillingColor,
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
                      ? const Color(0xFFFF4081)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    fillingColor,
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/images/fillings/fillingForCatalog.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filling.name,
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