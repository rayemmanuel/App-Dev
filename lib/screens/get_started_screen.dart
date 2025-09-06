import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top third
          Expanded(
            flex: 1,
            child: Container(color: Color.fromARGB(255, 123, 121, 119)),
          ),
          // Middle third
          Expanded(
            flex: 1,
            child: Container(color: Color.fromARGB(255, 94, 87, 76)),
          ),
          // Bottom third, split into two halves
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(color: Color.fromARGB(255, 155, 151, 144)),
                ),
                Expanded(
                  child: Container(color: Color.fromARGB(255, 143, 126, 100)),
                ),
              ],
            ),
          ),
        ],
      ),
      // Place button in the center of the screen
      floatingActionButton: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          child: Text(
            "Get Started!",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
