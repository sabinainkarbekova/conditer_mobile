import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autofocus;

  const SearchBar({
    Key? key,
    required this.onTap,
    this.onChanged,
    this.hintText = 'Поиск товаров...',
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}