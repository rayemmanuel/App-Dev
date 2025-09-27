// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'my_forma_screen.dart';
import '../models/user_profile_model.dart';
import 'forms_screen.dart';
import 'palette_screen.dart';
import 'bodyshape_results.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<UserProfileModel>(context, listen: false);
      model.setNavigationIndex(widget.initialIndex);
    });
  }

  void _onItemTapped(int index) {
    Provider.of<UserProfileModel>(
      context,
      listen: false,
    ).setNavigationIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context);

    print(
      '[MAIN] build index=${userProfile.navigationIndex} '
      'isProfileComplete=${userProfile.isProfileComplete} '
      'bodyType=${userProfile.bodyType}',
    );

    final screens = [
      HomeScreenContent(
        onNavigateToForm: () => _onItemTapped(2),
        onNavigateToPalette: () => _onItemTapped(1),
      ),
      const PaletteScreen(),
      userProfile.bodyType != null && userProfile.bodyType!.isNotEmpty
          ? BodyShapeResultsScreen(shape: userProfile.bodyType!)
          : const FormsScreen(),
      const MyFormaScreen(),
    ];

    final selectedIndex = userProfile.navigationIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      appBar: AppBar(
        title: Text(
          "FORMA",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: const Color(0xFFE7DFD8),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Palette'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Forma'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF8B7355),
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final VoidCallback onNavigateToForm;
  final VoidCallback onNavigateToPalette;

  const HomeScreenContent({
    super.key,
    required this.onNavigateToForm,
    required this.onNavigateToPalette,
  });

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(userProfile),
          const SizedBox(height: 24),
          _buildProgressSection(userProfile),
          const SizedBox(height: 24),
          if (userProfile.isProfileComplete) ...[
            _buildResultsSection(userProfile),
            const SizedBox(height: 24),
            _buildRecommendationsSection(userProfile),
            const SizedBox(height: 24),
          ],
          _buildActionCards(userProfile, onNavigateToForm, onNavigateToPalette),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(UserProfileModel userProfile) {
    return Center(
      child: Column(
        children: [
          Text(
            userProfile.isProfileComplete ? "Hello, Fashionista!" : "FORMA",
            style: GoogleFonts.inter(
              fontSize: userProfile.isProfileComplete ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: userProfile.isProfileComplete ? 1 : 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile.isProfileComplete
                ? "Your personalized style profile is ready"
                : "Every Form. Every Shade. Sustainable & True.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: userProfile.isProfileComplete ? 16 : 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(UserProfileModel userProfile) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB5A491), Color(0xFF8B7355)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userProfile.isProfileComplete ? "Profile Complete!" : "Get Started",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressStep(
                "1",
                "Body Type",
                userProfile.isBodyTypeComplete,
              ),
              _buildProgressLine(),
              _buildProgressStep(
                "2",
                "Skin Tone",
                userProfile.isSkinToneComplete,
              ),
              _buildProgressLine(),
              _buildProgressStep("✨", "Results", userProfile.isProfileComplete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String number, String label, bool completed) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFF10b981)
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 30,
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildResultsSection(UserProfileModel userProfile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Your Style Profile",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildResultItem("Body Type:", userProfile.bodyType ?? ""),
          const SizedBox(height: 8),
          _buildResultItem("Undertone:", userProfile.skinUndertone ?? ""),
          const SizedBox(height: 8),
          _buildResultItem("Profile:", "Complete ✓"),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7DFD8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF8B7355),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(UserProfileModel userProfile) {
    final recommendations = userProfile.styleRecommendations;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Color Palette",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: userProfile.colorPalette
                .map(
                  (color) => Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            "Recommended Styles",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Loop through categories
          ...recommendations.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7DFD8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            items[index],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionCards(
    UserProfileModel userProfile,
    VoidCallback onNavigateToForm,
    VoidCallback onNavigateToPalette,
  ) {
    return Column(
      children: [
        _buildActionCard(
          "Calculate Body Type",
          "Enter your measurements to discover your body type and get tailored fit recommendations.",
          userProfile.isBodyTypeComplete ? "Complete" : "Start",
          userProfile.isBodyTypeComplete
              ? "Edit Forma Data"
              : "Begin Forma Calculator",
          userProfile.isBodyTypeComplete,
          onNavigateToForm,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          "Analyze Skin Tone",
          "Upload your photo to identify your undertone and get your perfect color palette.",
          userProfile.isSkinToneComplete ? "Complete" : "Start",
          userProfile.isSkinToneComplete
              ? "Update Palette"
              : "Upload to Palette",
          userProfile.isSkinToneComplete,
          onNavigateToPalette,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    String statusText,
    String buttonText,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF8B7355)
              : const Color(0xFFD4C4B0),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE7DFD8)
                      : const Color(0xFFD4C4B0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? const Color(0xFFE7DFD8)
                    : const Color(0xFF8B7355),
                foregroundColor: isCompleted ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
