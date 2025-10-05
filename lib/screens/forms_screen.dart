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
  int currentStep = 0;
  final PageController _pageController = PageController();

  // Controllers for each step
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bustController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController highHipController = TextEditingController();
  final TextEditingController hipsController = TextEditingController();

  String heightUnit = "cm";
  String weightUnit = "kg";
  String bustUnit = "cm";
  String waistUnit = "cm";
  String highHipUnit = "cm";
  String hipsUnit = "cm";

  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getResults();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _getResults() {
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    String? gender = userProfile.gender; // Get gender from user profile

    // Get measurements in cm
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
    double height = _convertToCm(
      double.tryParse(heightController.text) ?? 0,
      heightUnit,
    );
    double weight = double.tryParse(weightController.text) ?? 0;

    String shape = "Undefined";

    if (gender == "Male") {
      // Male body type calculation using Sheldon's somatotypes
      // Calculate BMI and body ratios
      double heightInMeters = height / 100;
      double bmi = weight / (heightInMeters * heightInMeters);

      // Calculate shoulder to hip ratio (using bust as proxy for shoulders)
      double shoulderHipRatio = bust / hips;

      // Calculate waist to hip ratio
      double waistHipRatio = waist / hips;

      // Ectomorph: Lean, slender, less body fat
      // Characteristics: higher metabolism, narrower frame
      if (bmi < 22 && waistHipRatio < 0.9 && shoulderHipRatio < 1.05) {
        shape = "Ectomorph";
      }
      // Mesomorph: Athletic, muscular, medium build
      // Characteristics: shoulders wider than hips, athletic build
      else if (bmi >= 22 &&
          bmi <= 27 &&
          shoulderHipRatio >= 1.05 &&
          waistHipRatio < 0.95) {
        shape = "Mesomorph";
      }
      // Endomorph: Stockier, more body fat, larger frame
      // Characteristics: larger midsection, stockier build
      else if (bmi > 25 || waistHipRatio >= 0.95) {
        shape = "Endomorph";
      }
      // Default to Mesomorph for athletic builds that don't fit clear categories
      else {
        shape = "Mesomorph";
      }
    } else {
      // Female body type calculation - Standard fashion/medical categories
      double bustMinusHips = bust - hips;
      double hipsMinusBust = hips - bust;
      double bustMinusWaist = bust - waist;
      double hipsMinusWaist = hips - waist;
      double waistHipRatio = waist / hips;
      double waistBustRatio = waist / bust;

      // Calculate if measurements are similar (within 5% difference)
      bool bustHipsSimilar = (bust - hips).abs() / ((bust + hips) / 2) < 0.05;
      bool bustWaistSimilar =
          (bust - waist).abs() / ((bust + waist) / 2) < 0.09;
      bool hipsWaistSimilar =
          (hips - waist).abs() / ((hips + waist) / 2) < 0.09;

      // Hourglass: Bust and hips similar width, defined waist
      // Waist-to-hip ratio < 0.75, bust and hips within 2.5 cm
      if (bustHipsSimilar &&
          waistHipRatio < 0.75 &&
          hipsMinusWaist >= 18 &&
          bustMinusWaist >= 18) {
        shape = "Hourglass";
      }
      // Pear/Triangle: Hips wider than shoulders/bust, defined waist
      // Hip measurement noticeably larger than bust
      else if (hipsMinusBust >= 5 &&
          hipsMinusWaist >= 18 &&
          waistHipRatio < 0.8) {
        shape = "Pear";
      }
      // Inverted Triangle: Shoulders/bust wider than hips
      // Little waist definition, broader upper body
      else if (bustMinusHips >= 5 &&
          (bustWaistSimilar || bustMinusWaist < 18)) {
        shape = "Inverted Triangle";
      }
      // Rectangle: Similar measurements throughout, little waist definition
      // Bust, waist, and hips roughly the same
      else if (bustHipsSimilar &&
          (bustWaistSimilar || hipsWaistSimilar) &&
          waistHipRatio >= 0.75) {
        shape = "Rectangle";
      }
      // Apple/Oval: Weight carried in midsection, narrower hips
      // Waist measurement larger relative to hips
      else if (waistHipRatio >= 0.8 && waist >= hips * 0.85) {
        shape = "Apple";
      }
      // Default to Rectangle if no clear category
      else {
        shape = "Rectangle";
      }
    }

    userProfile.updateBodyType(shape);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Body type: $shape calculated!'),
        duration: const Duration(seconds: 2),
      ),
    );

    userProfile.setNavigationIndex(2);
  }

  double _convertToCm(double value, String unit) {
    switch (unit) {
      case "in":
        return value * 2.54;
      default:
        return value;
    }
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0:
        return heightController.text.isNotEmpty &&
            weightController.text.isNotEmpty;
      case 1:
        return bustController.text.isNotEmpty &&
            waistController.text.isNotEmpty;
      case 2:
        return highHipController.text.isNotEmpty &&
            hipsController.text.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7DFD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (currentStep > 0) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Body Shape Analysis',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content - Scrollable (including progress indicator)
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicMeasurementsStep(),
                  _buildBodyMeasurementsStep1(),
                  _buildBodyMeasurementsStep2(),
                ],
              ),
            ),

            // Bottom Navigation Buttons - Fixed at bottom
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7DFD8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFB5A491)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFB5A491),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Previous',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFB5A491),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed()
                            ? const Color(0xFFB5A491)
                            : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentStep == 2 ? 'Calculate' : 'Next',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            currentStep == 2
                                ? Icons.calculate
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isCompleted) {
    bool isCurrentStep = step == currentStep;
    bool isPastStep = step < currentStep;
    bool isActive = isPastStep || isCurrentStep;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFB5A491) : Colors.grey[300],
        shape: BoxShape.circle,
        border: isCurrentStep
            ? Border.all(color: const Color(0xFF8B7355), width: 3)
            : null,
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: GoogleFonts.inter(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.w600,
            fontSize: isCurrentStep ? 18 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 50,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFB5A491) : Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBasicMeasurementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator at the top of scrollable content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, currentStep >= 0),
                _buildStepLine(currentStep > 0),
                _buildStepIndicator(1, currentStep >= 1),
                _buildStepLine(currentStep > 1),
                _buildStepIndicator(2, currentStep >= 2),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB5A491),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.straighten, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),

          Text(
            'Basic Measurements',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Let's start with your height and weight",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _buildMeasurementField(
            title: "Height (cm)",
            controller: heightController,
            selectedUnit: heightUnit,
            onUnitChanged: (val) => setState(() => heightUnit = val),
            hintText: "e.g., 165",
            icon: Icons.height,
          ),
          const SizedBox(height: 24),

          _buildMeasurementField(
            title: "Weight (kg)",
            controller: weightController,
            selectedUnit: weightUnit,
            onUnitChanged: (val) => setState(() => weightUnit = val),
            hintText: "e.g., 60",
            icon: Icons.monitor_weight,
          ),
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildBodyMeasurementsStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator at the top of scrollable content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, currentStep >= 0),
                _buildStepLine(currentStep > 0),
                _buildStepIndicator(1, currentStep >= 1),
                _buildStepLine(currentStep > 1),
                _buildStepIndicator(2, currentStep >= 2),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB5A491),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.accessibility,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Upper Body',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Measure your bust and waist",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _buildMeasurementField(
            title: "Bust (cm)",
            controller: bustController,
            selectedUnit: bustUnit,
            onUnitChanged: (val) => setState(() => bustUnit = val),
            hintText: "e.g., 88",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 24),

          _buildMeasurementField(
            title: "Waist (cm)",
            controller: waistController,
            selectedUnit: waistUnit,
            onUnitChanged: (val) => setState(() => waistUnit = val),
            hintText: "e.g., 70",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildBodyMeasurementsStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator at the top of scrollable content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, currentStep >= 0),
                _buildStepLine(currentStep > 0),
                _buildStepIndicator(1, currentStep >= 1),
                _buildStepLine(currentStep > 1),
                _buildStepIndicator(2, currentStep >= 2),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB5A491),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Lower Body',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Measure your high hip and hips",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _buildMeasurementField(
            title: "High Hip (cm)",
            controller: highHipController,
            selectedUnit: highHipUnit,
            onUnitChanged: (val) => setState(() => highHipUnit = val),
            hintText: "e.g., 85",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 24),

          _buildMeasurementField(
            title: "Hips (cm)",
            controller: hipsController,
            selectedUnit: hipsUnit,
            onUnitChanged: (val) => setState(() => hipsUnit = val),
            hintText: "e.g., 95",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 100), // Extra padding for keyboard
        ],
      ),
    );
  }

  Widget _buildMeasurementField({
    required String title,
    required TextEditingController controller,
    required String selectedUnit,
    required Function(String) onUnitChanged,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFB5A491),
                  width: 2,
                ),
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}
