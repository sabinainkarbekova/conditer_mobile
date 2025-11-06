import 'package:flutter/material.dart';
import '../models/cream.dart';
import '../models/cake_model.dart';
import '../services/api_service.dart';
import 'filling_selection.dart';

class CreamSelectionScreen extends StatefulWidget {
  final CakeModel cakeModel;
  final ApiService apiService;

  const CreamSelectionScreen({
    Key? key,
    required this.cakeModel,
    required this.apiService,
  }) : super(key: key);

  @override
  _CreamSelectionScreenState createState() => _CreamSelectionScreenState();
}

class _CreamSelectionScreenState extends State<CreamSelectionScreen> {
  List<CreamModel> _creams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCreams();
  }

  Future<void> _loadCreams() async {
    try {
      final creams = await widget.apiService.getCreams();
      setState(() {
        _creams = creams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onCreamSelected(CreamModel cream) {
    setState(() {
      widget.cakeModel.selectCream(
        cream.id,
        color: _hexToColor(cream.hexCode),
      );
    });
  }

  void _onNextPressed() {
    if (widget.cakeModel.selectedCreamId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FillingSelectionScreen(
            cakeModel: widget.cakeModel,
            apiService: widget.apiService,
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    widget.cakeModel.selectCream(null);
    Navigator.of(context).pop();
  }

  Color _hexToColor(String hexCode) {
    return Color(int.parse('0xff${hexCode.replaceAll('#', '')}'));
  }

  @override
  Widget build(BuildContext context) {
    CreamModel? selectedCream;
    if (widget.cakeModel.selectedCreamId != null) {
      try {
        selectedCream = _creams.firstWhere(
              (cream) => cream.id == widget.cakeModel.selectedCreamId,
        );
      } catch (e) {
        selectedCream = null;
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
              onPressed: _loadCreams,
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
                // 3D Cake Preview with Cream
                _build3DCakePreview(selectedCream),

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
                    'Выберите крем',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Cream Selection Cards
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _creams.length,
                    itemBuilder: (context, index) {
                      final cream = _creams[index];
                      final isSelected =
                          widget.cakeModel.selectedCreamId == cream.id;

                      return _CreamCard(
                        cream: cream,
                        isSelected: isSelected,
                        creamColor: _hexToColor(cream.hexCode),
                        onTap: () => _onCreamSelected(cream),
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
                    onPressed: widget.cakeModel.selectedCreamId != null
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

  Widget _build3DCakePreview(CreamModel? selectedCream) {
    Color layerColor = widget.cakeModel.selectedLayerColor ?? Colors.grey[300]!;
    Color creamColor = widget.cakeModel.selectedCreamColor ??
        (selectedCream != null ? _hexToColor(selectedCream.hexCode) : Colors.white);

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

          // Cream (если выбран)
          if (selectedCream != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                creamColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/creams/cream1.png',
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

class _CreamCard extends StatelessWidget {
  final CreamModel cream;
  final bool isSelected;
  final Color creamColor;
  final VoidCallback onTap;

  const _CreamCard({
    required this.cream,
    required this.isSelected,
    required this.creamColor,
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
                    creamColor,
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/images/creams/creamForCatalog.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cream.name,
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