import 'package:flutter/material.dart';
import '../models/cake_model.dart';

class CakePreview extends StatelessWidget {
  final CakeModel cakeModel;

  const CakePreview({Key? key, required this.cakeModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.pink[50],
      ),
      child: Stack(
        children: [
          // Корж (основа)
          if (cakeModel.selectedLayerId != null)
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: const Color(0xFFF4A460), // Цвет коржа
              ),
            ),

          // Крем
          if (cakeModel.selectedCreamId != null)
            Container(
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                color: Colors.pink[100],
              ),
            ),

          // Покрытие
          if (cakeModel.selectedCoatingId != null)
            Container(
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: cakeModel.selectedColorId != null
                    ? Colors.white // Здесь будет реальный цвет из API
                    : Colors.pink[200],
              ),
            ),
        ],
      ),
    );
  }
}