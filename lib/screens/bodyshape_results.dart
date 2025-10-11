// lib/screens/bodyshape_results.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile_model.dart';

class BodyShapeResultsScreen extends StatelessWidget {
  final String shape;

  const BodyShapeResultsScreen({super.key, required this.shape});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context, listen: false);
    final isMale = userProfile.gender?.toLowerCase() == "male";

    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Celebration Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFB5A491),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Congratulations Text
              Text(
                'Your Results Are Ready!',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isMale ? 'Your Body Type:' : 'Your Body Shape:',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7DFD8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        shape,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B7355),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Body Shape/Type Illustration
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7DFD8),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        _getShapeIcon(shape, isMale),
                        size: 60,
                        color: const Color(0xFFB5A491),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _getShapeDescription(shape, isMale),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Motivational Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB5A491), Color(0xFF8B7355)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isMale
                      ? 'Ready to discover clothing that complements your build and enhances your natural physique?'
                      : 'Ready to discover your perfect wardrobe that celebrates your unique body shape?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        userProfile.setNavigationIndex(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7355),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Explore Your Profile',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        userProfile.updateBodyType("");
                        userProfile.setNavigationIndex(2);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B7355),
                        side: const BorderSide(
                          color: Color(0xFF8B7355),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Recalculate',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getShapeIcon(String shape, bool isMale) {
    if (isMale) {
      // Male somatotype icons
      switch (shape.toLowerCase()) {
        case 'ectomorph':
          return Icons.accessibility_new;
        case 'mesomorph':
          return Icons.fitness_center;
        case 'endomorph':
          return Icons.account_circle;
        default:
          return Icons.person;
      }
    } else {
      // Female body shape icons
      switch (shape.toLowerCase()) {
        case 'hourglass':
          return Icons.hourglass_empty;
        case 'pear':
          return Icons.landscape;
        case 'inverted triangle':
          return Icons.keyboard_arrow_up;
        case 'rectangle':
          return Icons.crop_square;
        case 'apple':
          return Icons.circle_outlined;
        default:
          return Icons.person;
      }
    }
  }

  String _getShapeDescription(String shape, bool isMale) {
    if (isMale) {
      // Male somatotype descriptions
      switch (shape.toLowerCase()) {
        case 'ectomorph':
          return 'Lean and slender build with a fast metabolism.\nYour naturally slim physique is your foundation for a sharp, tailored look!';
        case 'mesomorph':
          return 'Athletic and muscular with balanced proportions.\nYour naturally strong build allows you to wear a wide range of styles with confidence!';
        case 'endomorph':
          return 'Solid build with a naturally stockier frame.\nYour robust physique gives you a strong, commanding presence!';
        default:
          return 'Your unique body type is the perfect canvas\nfor your personal style!';
      }
    } else {
      // Female body shape descriptions
      switch (shape.toLowerCase()) {
        case 'hourglass':
          return 'Balanced proportions with a defined waist.\nYour curves are perfectly balanced!';
        case 'pear':
          return 'Fuller hips with a smaller bust.\nYour lower body curves are beautiful!';
        case 'inverted triangle':
          return 'Broader shoulders with narrower hips.\nYour strong upper body is striking!';
        case 'rectangle':
          return 'Balanced and athletic build.\nYour straight silhouette is elegant!';
        case 'apple':
          return 'Weight carried in the midsection with slender legs.\nYour proportions create a graceful silhouette!';
        default:
          return 'Your unique body shape is beautiful\njust the way it is!';
      }
    }
  }
}
