// lib/features/cake/presentation/pages/summary_page.dart
import 'package:flutter/material.dart';

import '../../../../models/cake_model.dart';
import '../../../../services/api_service.dart';
import '../../../cart/presentation/screens/success_screen.dart';


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
        _saveError = 'Not all cake components are selected';
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
        _saveSuccess = 'Cake saved successfully!';
      });

      // Automatically navigate to SuccessScreen after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Переход на SuccessScreen, заменяя SummaryPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SuccessScreen()),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _saveError = 'Save error: $e';
      });
    }
  }

  // Function for the "Back" button - returns to the previous screen in the stack
  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  // Function for the "Start Over" button - navigates to ProfileScreen
  void _onStartOver() {
    widget.cakeModel.clearAll();
    // Navigate to ProfileScreen, replacing the current screen
    Navigator.of(context).pushReplacementNamed('/profile');
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
              color: isSelected ? Colors.pink : Colors.grey[300],
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
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  value ?? 'Not selected',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: isSelected ? Colors.pink : Colors.grey[500],
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
          // Layer (if selected)
          if (widget.cakeModel.selectedLayerId != null)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                layerColor,
                BlendMode.modulate,
              ),
              child: Image.asset(
                'assets/images/layers/layer4.png', // Make sure this path is correct
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
      // Removed AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              // Header with "Back" button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: _onBackPressed,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Add logo if needed
                  // Image.asset(
                  //   'assets/images/logo.png', // Specify the path to your logo
                  //   height: 40,
                  //   fit: BoxFit.contain,
                  // ),
                ],
              ),
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
                decoration: BoxDecoration(
                  color: Colors.pink, // Pink color
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: const Text(
                  'Your Cake is Ready!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Cake details
              Expanded( // Make the details list scrollable
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink[50], // Light pink background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildSelectionItem(
                          'Layer',
                          'Selected',
                          widget.cakeModel.selectedLayerId != null,
                        ),
                        _buildSelectionItem(
                          'Cream',
                          'Selected',
                          widget.cakeModel.selectedCreamId != null,
                        ),
                        _buildSelectionItem(
                          'Filling',
                          'Selected',
                          widget.cakeModel.selectedFillingId != null,
                        ),
                        _buildSelectionItem(
                          'Coating',
                          'Selected',
                          widget.cakeModel.selectedCoatingId != null,
                        ),
                        _buildSelectionItem(
                          'Coating Color',
                          'Selected',
                          widget.cakeModel.selectedColorId != null,
                        ),
                        _buildSelectionItem(
                          'Decorations',
                          '${widget.cakeModel.decorations.length} items',
                          widget.cakeModel.decorations.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error/Success messages
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Bottom Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveCake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink, // Pink color
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
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
                          : Text(
                        'Save Cake',
                        style: TextStyle(
                          fontFamily: 'Poppins',
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
                        backgroundColor: Colors.pink[50], // Light pink
                        foregroundColor: Colors.pink, // Text pink
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                          side: BorderSide(
                            color: Colors.pink, // Pink border
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Build New Cake',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}