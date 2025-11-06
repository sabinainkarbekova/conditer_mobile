import 'package:flutter/material.dart';

class AdvancedSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onCancel;
  final String hintText;

  const AdvancedSearchBar({
    Key? key,
    required this.onSearch,
    required this.onCancel,
    this.hintText = 'Поиск товаров...',
  }) : super(key: key);

  @override
  _AdvancedSearchBarState createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              style: TextStyle(fontSize: 14),
              onChanged: (value) {
                widget.onSearch(value);
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onCancel();
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 30, maxWidth: 30),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}