// lib/screens/forms_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile_model.dart';
import '../utils/transitions_helper.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    heightController.dispose();
    weightController.dispose();
    bustController.dispose();
    waistController.dispose();
    hipsController.dispose();
    shoulderController.dispose();
    chestController.dispose();
    waistMaleController.dispose();
    wristController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _slideController.reset();
      _slideController.forward();
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
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
        behavior: SnackBarBehavior.floating,
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
        automaticallyImplyLeading: false,
        elevation: 0,
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
            AnimatedSlideIn(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              begin: const Offset(0, 0.5),
              child: Container(
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
                      child: AnimatedButton(
                        onPressed: _canProceed() ? _nextStep : null,
                        enabled: _canProceed(),
                        isLastStep: currentStep == 2,
                      ),
                    ),
                  ],
                ),
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (step * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFB5A491) : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrentStep
                  ? Border.all(color: const Color(0xFF8B7355), width: 3)
                  : null,
              boxShadow: isCurrentStep
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB5A491).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
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
          ),
        );
      },
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5A491),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Basic Measurements',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 250),
            child: Text(
              "Let's start with your height and weight",
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          StaggeredListItem(
            index: 0,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Height (cm)",
              controller: heightController,
              hintText: "e.g., 165",
              icon: Icons.height,
            ),
          ),
          const SizedBox(height: 24),
          StaggeredListItem(
            index: 1,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Weight (kg)",
              controller: weightController,
              hintText: "e.g., 60",
              icon: Icons.monitor_weight,
            ),
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
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Upper Body',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 250),
            child: Text(
              'Measure shoulders, chest, and waist',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          StaggeredListItem(
            index: 0,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Shoulder Width (cm)",
              controller: shoulderController,
              hintText: "e.g., 45",
              icon: Icons.straighten,
              helpText: "Measure from left to right shoulder bone",
            ),
          ),
          const SizedBox(height: 24),
          StaggeredListItem(
            index: 1,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Chest (cm)",
              controller: chestController,
              hintText: "e.g., 100",
              icon: Icons.straighten,
              helpText: "Around fullest part of chest",
            ),
          ),
          const SizedBox(height: 24),
          StaggeredListItem(
            index: 2,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Waist (cm)",
              controller: waistMaleController,
              hintText: "e.g., 85",
              icon: Icons.straighten,
              helpText: "Around belly button level",
            ),
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
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5A491),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.watch,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Frame Size',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 250),
            child: Text(
              'This helps determine your bone structure',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          StaggeredListItem(
            index: 0,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Wrist Circumference (cm)",
              controller: wristController,
              hintText: "e.g., 17",
              icon: Icons.straighten,
              helpText: "Around the narrowest part of your wrist",
            ),
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
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Upper Body',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 250),
            child: Text(
              'Measure your bust and waist',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          StaggeredListItem(
            index: 0,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Bust (cm)",
              controller: bustController,
              hintText: "e.g., 88",
              icon: Icons.straighten,
            ),
          ),
          const SizedBox(height: 24),
          StaggeredListItem(
            index: 1,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Waist (cm)",
              controller: waistController,
              hintText: "e.g., 70",
              icon: Icons.straighten,
            ),
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
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Lower Body',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSlideIn(
            duration: const Duration(milliseconds: 500),
            delay: const Duration(milliseconds: 250),
            child: Text(
              'Measure your hips',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          StaggeredListItem(
            index: 0,
            baseDelay: const Duration(milliseconds: 100),
            child: _buildMeasurementField(
              title: "Hips (cm)",
              controller: hipsController,
              hintText: "e.g., 95",
              icon: Icons.straighten,
            ),
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

// Animated Button Widget
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLastStep;

  const AnimatedButton({
    super.key,
    this.onPressed,
    required this.enabled,
    required this.isLastStep,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _controller.forward() : null,
      onTapUp: widget.enabled ? (_) => _controller.reverse() : null,
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.enabled
                ? const Color(0xFFB5A491)
                : Colors.grey[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: widget.enabled ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isLastStep ? 'Calculate' : 'Next',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                widget.isLastStep ? Icons.calculate : Icons.arrow_forward,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
