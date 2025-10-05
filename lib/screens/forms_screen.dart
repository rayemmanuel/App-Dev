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

  // Controllers - Basic measurements (both genders)
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Controllers - Female specific
  final TextEditingController bustController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController hipsController = TextEditingController();

  // Controllers - Male specific
  final TextEditingController shoulderController = TextEditingController();
  final TextEditingController chestController = TextEditingController();
  final TextEditingController waistMaleController = TextEditingController();
  final TextEditingController wristController = TextEditingController();

  String heightUnit = "cm";
  String weightUnit = "kg";
  String measurementUnit = "cm";

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
    String? gender = userProfile.gender;

    double height = _convertToCm(
      double.tryParse(heightController.text) ?? 0,
      heightUnit,
    );
    double weight = double.tryParse(weightController.text) ?? 0;

    String shape = "Undefined";

    if (gender == "Male") {
      // Male-specific measurements
      double shoulder = _convertToCm(
        double.tryParse(shoulderController.text) ?? 0,
        measurementUnit,
      );
      double chest = _convertToCm(
        double.tryParse(chestController.text) ?? 0,
        measurementUnit,
      );
      double waist = _convertToCm(
        double.tryParse(waistMaleController.text) ?? 0,
        measurementUnit,
      );
      double wrist = _convertToCm(
        double.tryParse(wristController.text) ?? 0,
        measurementUnit,
      );

      // Calculate BMI
      double heightInMeters = height / 100;
      double bmi = weight / (heightInMeters * heightInMeters);

      // Calculate ratios
      double shoulderToWaist = shoulder / waist;
      double chestToWaist = chest / waist;

      // Frame size based on wrist
      bool smallFrame = wrist < 16.5;
      bool largeFrame = wrist > 19;

      // ECTOMORPH: Lean, hard gainer
      if (bmi < 20 || (bmi <= 22 && smallFrame && (chest - waist) < 12)) {
        shape = "Ectomorph";
      }
      // MESOMORPH: Athletic, V-taper
      else if (bmi >= 20 &&
          bmi <= 26 &&
          shoulderToWaist >= 1.3 &&
          chestToWaist >= 1.2 &&
          (chest - waist) >= 15) {
        shape = "Mesomorph";
      }
      // ENDOMORPH: Stockier, easier fat gain
      else if (bmi > 26 || shoulderToWaist < 1.2 || (chest - waist) < 10) {
        shape = "Endomorph";
      }
      // Edge cases
      else {
        if (smallFrame && bmi <= 23) {
          shape = "Ectomorph";
        } else if (largeFrame || bmi > 25) {
          shape = "Endomorph";
        } else {
          shape = "Mesomorph";
        }
      }
    } else {
      // Female body types based on the article's definitions
      double bust = _convertToCm(
        double.tryParse(bustController.text) ?? 0,
        measurementUnit,
      );
      double waist = _convertToCm(
        double.tryParse(waistController.text) ?? 0,
        measurementUnit,
      );
      double hips = _convertToCm(
        double.tryParse(hipsController.text) ?? 0,
        measurementUnit,
      );

      // Calculate key differences and ratios
      double bustMinusHips = bust - hips;
      double hipsMinusBust = hips - bust;
      double bustMinusWaist = bust - waist;
      double hipsMinusWaist = hips - waist;
      double waistHipRatio = waist / hips;

      // HOURGLASS: "bust and hips the same width" + "smaller defined waist"
      if ((bust - hips).abs() <= 5 &&
          waistHipRatio < 0.75 &&
          hipsMinusWaist >= 18 &&
          bustMinusWaist >= 18) {
        shape = "Hourglass";
      }
      // PEAR/TRIANGLE: "narrower shoulders than hips" + "defined waist"
      else if (hipsMinusBust >= 5 &&
          hipsMinusWaist >= 15 &&
          waistHipRatio <= 0.8) {
        shape = "Pear";
      }
      // INVERTED TRIANGLE: "lower half smaller than top" + "shoulders wider than hips"
      else if (bustMinusHips >= 5 &&
          (bustMinusWaist < 15 || waistHipRatio >= 0.8)) {
        shape = "Inverted Triangle";
      }
      // APPLE/OVAL: "top and bottom halves narrow" + "weight in chest and stomach"
      else if (waist >= bust * 0.9 ||
          (waistHipRatio >= 0.85 && bustMinusWaist < 10)) {
        shape = "Apple";
      }
      // RECTANGLE: "no major definition at waistline" + "similar hip and shoulder width"
      else if ((bust - hips).abs() <= 5 &&
          (waistHipRatio >= 0.75 || hipsMinusWaist < 15)) {
        shape = "Rectangle";
      }
      // Default to Rectangle
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
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    String? gender = userProfile.gender;

    switch (currentStep) {
      case 0:
        return heightController.text.isNotEmpty &&
            weightController.text.isNotEmpty;
      case 1:
        if (gender == "Male") {
          return shoulderController.text.isNotEmpty &&
              chestController.text.isNotEmpty &&
              waistMaleController.text.isNotEmpty;
        } else {
          return bustController.text.isNotEmpty &&
              waistController.text.isNotEmpty;
        }
      case 2:
        if (gender == "Male") {
          return wristController.text.isNotEmpty;
        } else {
          return hipsController.text.isNotEmpty;
        }
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

  Widget _buildProgressIndicator() {
    return Container(
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
    );
  }

  Widget _buildBasicMeasurementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 10),
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
            hintText: "e.g., 165",
            icon: Icons.height,
          ),
          const SizedBox(height: 24),
          _buildMeasurementField(
            title: "Weight (kg)",
            controller: weightController,
            hintText: "e.g., 60",
            icon: Icons.monitor_weight,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBodyMeasurementsStep1() {
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    String? gender = userProfile.gender;

    if (gender == "Male") {
      return _buildMaleUpperBodyStep();
    } else {
      return _buildFemaleUpperBodyStep();
    }
  }

  Widget _buildBodyMeasurementsStep2() {
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    String? gender = userProfile.gender;

    if (gender == "Male") {
      return _buildMaleFrameStep();
    } else {
      return _buildFemaleLowerBodyStep();
    }
  }

  Widget _buildMaleUpperBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB5A491),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fitness_center,
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
            'Measure shoulders, chest, and waist',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildMeasurementField(
            title: "Shoulder Width (cm)",
            controller: shoulderController,
            hintText: "e.g., 45",
            icon: Icons.straighten,
            helpText: "Measure from left to right shoulder bone",
          ),
          const SizedBox(height: 24),
          _buildMeasurementField(
            title: "Chest (cm)",
            controller: chestController,
            hintText: "e.g., 100",
            icon: Icons.straighten,
            helpText: "Around fullest part of chest",
          ),
          const SizedBox(height: 24),
          _buildMeasurementField(
            title: "Waist (cm)",
            controller: waistMaleController,
            hintText: "e.g., 85",
            icon: Icons.straighten,
            helpText: "Around belly button level",
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMaleFrameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB5A491),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.watch, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Frame Size',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps determine your bone structure',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildMeasurementField(
            title: "Wrist Circumference (cm)",
            controller: wristController,
            hintText: "e.g., 17",
            icon: Icons.straighten,
            helpText: "Around the narrowest part of your wrist",
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFemaleUpperBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        children: [
          _buildProgressIndicator(),
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
            'Measure your bust and waist',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildMeasurementField(
            title: "Bust (cm)",
            controller: bustController,
            hintText: "e.g., 88",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 24),
          _buildMeasurementField(
            title: "Waist (cm)",
            controller: waistController,
            hintText: "e.g., 70",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFemaleLowerBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Column(
        children: [
          _buildProgressIndicator(),
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
            'Measure your hips',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildMeasurementField(
            title: "Hips (cm)",
            controller: hipsController,
            hintText: "e.g., 95",
            icon: Icons.straighten,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMeasurementField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? helpText,
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
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
          ),
        ],
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
