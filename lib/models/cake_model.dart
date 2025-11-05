import 'package:flutter/material.dart';
import 'decoration.dart';

class CakeModel extends ChangeNotifier {
  int? _selectedLayerId;
  Color? _selectedLayerColor;
  int? _selectedCreamId;
  Color? _selectedCreamColor;
  int? _selectedFillingId;
  Color? _selectedFillingColor;
  int? _selectedCoatingId;
  int? _selectedColorId;
  final List<DecorationPlacement> _decorations = [];

  int? get selectedLayerId => _selectedLayerId;
  Color? get selectedLayerColor => _selectedLayerColor;
  int? get selectedCreamId => _selectedCreamId;
  Color? get selectedCreamColor => _selectedCreamColor; // Геттер для цвета крема
  int? get selectedFillingId => _selectedFillingId;
  Color? get selectedFillingColor => _selectedFillingColor;
  int? get selectedCoatingId => _selectedCoatingId;
  int? get selectedColorId => _selectedColorId;
  List<DecorationPlacement> get decorations => _decorations;

  void selectLayer(int? layerId, {Color? color}) {
    _selectedLayerId = layerId;
    _selectedLayerColor = color;
    notifyListeners();
  }

  void selectCream(int? creamId, {Color? color}) { // Добавляем параметр color
    _selectedCreamId = creamId;
    _selectedCreamColor = color; // сохраняем цвет крема
    notifyListeners();
  }

  void selectFilling(int? fillingId, {Color? color}) { // Добавляем параметр color
    _selectedFillingId = fillingId;
    _selectedFillingColor = color; // сохраняем цвет начинки
    notifyListeners();
  }

  void selectCoating(int? coatingId) {
    _selectedCoatingId = coatingId;
    notifyListeners();
  }

  void selectColor(int? colorId) {
    _selectedColorId = colorId;
    notifyListeners();
  }

  void addDecoration(DecorationPlacement decoration) {
    _decorations.add(decoration);
    notifyListeners();
  }

  void updateDecoration(int index, DecorationPlacement decoration) {
    if (index >= 0 && index < _decorations.length) {
      _decorations[index] = decoration;
      notifyListeners();
    }
  }

  void removeDecoration(int index) {
    if (index >= 0 && index < _decorations.length) {
      _decorations.removeAt(index);
      notifyListeners();
    }
  }

  void clearDecorations() {
    _decorations.clear();
    notifyListeners();
  }

  void clearAll() {
    _selectedLayerId = null;
    _selectedLayerColor = null;
    _selectedCreamId = null;
    _selectedCreamColor = null; // очищаем цвет крема
    _selectedFillingId = null;
    _selectedCoatingId = null;
    _selectedColorId = null;
    _decorations.clear();
    notifyListeners();
  }

  bool get isComplete {
    return _selectedLayerId != null &&
        _selectedCreamId != null &&
        _selectedFillingId != null &&
        _selectedCoatingId != null &&
        _selectedColorId != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': 1,
      'cakeTypeId': 1,
      'layerId': _selectedLayerId,
      'creamId': _selectedCreamId,
      'fillingId': _selectedFillingId,
      'coatingId': _selectedCoatingId,
      'coatingColorId': _selectedColorId,
      'comment': 'Создано через Flutter',
      'decorations': _decorations.map((d) => d.toJson()).toList(),
    };
  }
}