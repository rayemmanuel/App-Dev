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

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Header card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Body Shape is: $shape",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 26),

            // Image placeholder
            Container(
              width: 260,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Image Here",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                "Are you searching for a wardrobe that flatters your body shape?",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 22),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Go back to Home section
                      userProfile.setNavigationIndex(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF947E62),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      "Check This Out!",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Reset profile so FormsScreen is incomplete
                      userProfile.updateBodyType(""); // clear body type
                      userProfile.setNavigationIndex(
                        2,
                      ); // switch to FormsScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      "Try Again",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
