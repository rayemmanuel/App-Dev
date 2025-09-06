import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Let's get your\nperfect Forma!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Select your preference to unlock\ntailored fashion insights",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF8E7E7E)),
            ),
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Text("Female"),
                  selected: selectedGender == "Female",
                  onSelected: (bool selected) {
                    setState(() {
                      selectedGender = "Female";
                    });
                  },
                  selectedColor: Colors.black,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: selectedGender == "Female"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                ChoiceChip(
                  label: Text("Male"),
                  selected: selectedGender == "Male",
                  onSelected: (bool selected) {
                    setState(() {
                      selectedGender = "Male";
                    });
                  },
                  selectedColor: Colors.black,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: selectedGender == "Male"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: selectedGender == null
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
