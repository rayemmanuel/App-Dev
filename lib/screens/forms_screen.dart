// lib/screens/forms_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile_model.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bustController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController highHipController = TextEditingController();
  final TextEditingController hipsController = TextEditingController();

  String bustUnit = "cm";
  String waistUnit = "cm";
  String highHipUnit = "cm";
  String hipsUnit = "cm";

  void _getResults() {
    if (_formKey.currentState!.validate()) {
      double bust = _convertToCm(
        double.tryParse(bustController.text) ?? 0,
        bustUnit,
      );
      double waist = _convertToCm(
        double.tryParse(waistController.text) ?? 0,
        waistUnit,
      );
      double highHip = _convertToCm(
        double.tryParse(highHipController.text) ?? 0,
        highHipUnit,
      );
      double hips = _convertToCm(
        double.tryParse(hipsController.text) ?? 0,
        hipsUnit,
      );

      String shape = "Undefined";
      if ((bust - hips).abs() <= 3 &&
          (bust - waist) >= 9 &&
          (hips - waist) >= 10) {
        shape = "Hourglass";
      } else if (hips - bust >= 3 && hips - waist >= 7) {
        shape = "Pear";
      } else if (bust - hips >= 3 && bust - waist >= 7) {
        shape = "Franco";
      } else {
        shape = "Rectangle";
      }

      // update provider
      final userProfile = Provider.of<UserProfileModel>(context, listen: false);
      userProfile.updateBodyType(shape);

      print(
        '[FORMS] after update: nav=${userProfile.navigationIndex} '
        'isProfileComplete=${userProfile.isProfileComplete} '
        'bodyType=${userProfile.bodyType}',
      );

      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Body type: $shape calculated!'),
          duration: const Duration(seconds: 2),
        ),
      );

      // ✅ instead of pushing a new screen, switch MainScreen to index 2
      userProfile.setNavigationIndex(2);
    }
  }

  double _convertToCm(double value, String unit) {
    switch (unit) {
      case "in":
        return value * 2.54;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "CALCULATE BODY SHAPE",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildMeasurementField(
                title: "Bust",
                controller: bustController,
                selectedUnit: bustUnit,
                onUnitChanged: (val) => setState(() => bustUnit = val),
              ),
              const SizedBox(height: 20),

              _buildMeasurementField(
                title: "Waist",
                controller: waistController,
                selectedUnit: waistUnit,
                onUnitChanged: (val) => setState(() => waistUnit = val),
              ),
              const SizedBox(height: 20),

              _buildMeasurementField(
                title: "High Hip",
                controller: highHipController,
                selectedUnit: highHipUnit,
                onUnitChanged: (val) => setState(() => highHipUnit = val),
              ),
              const SizedBox(height: 20),

              _buildMeasurementField(
                title: "Hips",
                controller: hipsController,
                selectedUnit: hipsUnit,
                onUnitChanged: (val) => setState(() => hipsUnit = val),
              ),
              const SizedBox(height: 50),

              Center(
                child: ElevatedButton(
                  onPressed: _getResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF947E62),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    "Get Results",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField({
    required String title,
    required TextEditingController controller,
    required String selectedUnit,
    required Function(String) onUnitChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.brown[900],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF947E62),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color(0xFF947E62),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.brown, width: 2),
                  ),
                  hintText: "Enter value",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF947E62), width: 1.5),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedUnit,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: "cm", child: Text("cm")),
                    DropdownMenuItem(value: "in", child: Text("Inches")),
                  ],
                  onChanged: (val) => onUnitChanged(val!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
