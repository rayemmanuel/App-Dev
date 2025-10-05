// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'undertone_analysis.dart';
import 'my_forma_screen.dart';
import '../models/user_profile_model.dart';
import 'forms_screen.dart';
import 'bodyshape_results.dart';
import 'category_detail_screen.dart';
import '../utils/transitions_helper.dart';

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
      const UndertoneAnalysisScreen(),
      userProfile.bodyType != null && userProfile.bodyType!.isNotEmpty
          ? BodyShapeResultsScreen(shape: userProfile.bodyType!)
          : const FormsScreen(),
      const MyFormaScreen(),
    ];

    final selectedIndex = userProfile.navigationIndex;

    return Scaffold(
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
          const SizedBox(height: 40),

          // Animate welcome section
          AnimatedSlideIn(
            delay: const Duration(milliseconds: 0),
            child: _buildWelcomeSection(userProfile),
          ),

          const SizedBox(height: 24),

          // Animate progress section
          AnimatedSlideIn(
            delay: const Duration(milliseconds: 100),
            child: _buildProgressSection(userProfile),
          ),

          const SizedBox(height: 24),

          if (userProfile.isProfileComplete) ...[
            // Animate results section
            AnimatedSlideIn(
              delay: const Duration(milliseconds: 200),
              child: _buildResultsSection(userProfile),
            ),

            const SizedBox(height: 24),

            // Animate personalized outfit
            AnimatedSlideIn(
              delay: const Duration(milliseconds: 300),
              child: _buildPersonalizedOutfitSection(context, userProfile),
            ),

            const SizedBox(height: 24),

            // Animate style tips
            AnimatedSlideIn(
              delay: const Duration(milliseconds: 400),
              child: _buildStyleTipsSection(userProfile),
            ),

            const SizedBox(height: 24),

            // Animate color palette
            AnimatedSlideIn(
              delay: const Duration(milliseconds: 500),
              child: _buildColorPaletteSection(userProfile),
            ),

            const SizedBox(height: 24),

            // Animate category grid
            AnimatedSlideIn(
              delay: const Duration(milliseconds: 600),
              child: _buildCategoryGrid(context, userProfile),
            ),

            const SizedBox(height: 24),
          ],

          // Animate action cards
          AnimatedSlideIn(
            delay: Duration(
              milliseconds: userProfile.isProfileComplete ? 700 : 200,
            ),
            child: _buildActionCards(
              userProfile,
              onNavigateToForm,
              onNavigateToPalette,
            ),
          ),
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
                "Skin Tone",
                userProfile.isSkinToneComplete,
              ),
              _buildProgressLine(),
              _buildProgressStep(
                "2",
                "Body Type",
                userProfile.isBodyTypeComplete,
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

  Widget _buildPersonalizedOutfitSection(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    final selectedOutfit = userProfile.selectedOutfit;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth - 40, // Account for the 20px padding on each side
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B7355), Color(0xFFB5A491)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Your Perfect Outfit",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Clear button - only show if there are items
              if (selectedOutfit.isNotEmpty)
                IconButton(
                  onPressed: () {
                    userProfile.clearOutfit();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Outfit cleared'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  tooltip: 'Clear outfit',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, // Takes full width of parent
            constraints: BoxConstraints(
              minHeight: 120, // Minimum height for empty state
              maxWidth: screenWidth - 88, // Account for brown container padding
            ),
            padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: selectedOutfit.isEmpty
                ? Column(
                    children: [
                      Icon(
                        Icons.checkroom_outlined,
                        size: 48,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No items selected yet",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Browse categories and tap 'Perfect Match' to add items",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${selectedOutfit.length} item${selectedOutfit.length != 1 ? 's' : ''} selected",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF8B7355),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...selectedOutfit.entries.map((entry) {
                        final category = entry.key;
                        final itemName = entry.value;
                        final clothingItem = userProfile.getClothingItem(
                          category,
                          itemName,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7DFD8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Image
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getPlaceholderColorForItem(
                                      itemName,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: clothingItem.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              clothingItem.imageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: clothingItem.imageUrl == null
                                      ? Icon(
                                          _getIconForItemName(itemName),
                                          size: 30,
                                          color: Colors.white.withOpacity(0.6),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Item info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemName,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF8B7355),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove button
                                IconButton(
                                  onPressed: () {
                                    userProfile.removeOutfitItem(category);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$itemName removed'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Color(0xFF8B7355),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _getPlaceholderColorForItem(String itemName) {
    final colorMap = {
      'warm': [
        const Color(0xFFD4AF37),
        const Color(0xFFCD853F),
        const Color(0xFFDAA520),
        const Color(0xFFB8860B),
      ],
      'cool': [
        const Color(0xFF4169E1),
        const Color(0xFF8A2BE2),
        const Color(0xFF20B2AA),
        const Color(0xFF9370DB),
      ],
      'neutral': [
        const Color(0xFF708090),
        const Color(0xFF2E8B57),
        const Color(0xFF800080),
        const Color(0xFFB22222),
      ],
    };

    final lowerName = itemName.toLowerCase();
    if (lowerName.contains('warm') ||
        lowerName.contains('camel') ||
        lowerName.contains('rust') ||
        lowerName.contains('olive') ||
        lowerName.contains('honey') ||
        lowerName.contains('terracotta')) {
      return colorMap['warm']![itemName.hashCode % 4];
    } else if (lowerName.contains('cool') ||
        lowerName.contains('navy') ||
        lowerName.contains('teal') ||
        lowerName.contains('lavender') ||
        lowerName.contains('charcoal')) {
      return colorMap['cool']![itemName.hashCode % 4];
    }
    return colorMap['neutral']![itemName.hashCode % 4];
  }

  IconData _getIconForItemName(String itemName) {
    final lowerName = itemName.toLowerCase();
    if (lowerName.contains('dress')) return Icons.checkroom;
    if (lowerName.contains('shirt') || lowerName.contains('blouse'))
      return Icons.shopping_bag;
    if (lowerName.contains('pants') ||
        lowerName.contains('jeans') ||
        lowerName.contains('trousers'))
      return Icons.yard;
    if (lowerName.contains('jacket') ||
        lowerName.contains('blazer') ||
        lowerName.contains('coat'))
      return Icons.dry_cleaning;
    if (lowerName.contains('shoes') ||
        lowerName.contains('boots') ||
        lowerName.contains('sneakers'))
      return Icons.shopping_basket;
    if (lowerName.contains('bag')) return Icons.work_outline;
    if (lowerName.contains('scarf') || lowerName.contains('tie'))
      return Icons.interests;
    return Icons.checkroom;
  }

  Widget _buildStyleTipsSection(UserProfileModel userProfile) {
    final tips = userProfile.styleTips;

    if (tips.isEmpty) return const SizedBox.shrink();

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
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF8B7355),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Style Tips for You",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.take(3).map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B7355),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildColorPaletteSection(UserProfileModel userProfile) {
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
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
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
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    UserProfileModel userProfile,
  ) {
    final isMale = userProfile.gender?.toLowerCase() == "male";
    final isFemale = userProfile.gender?.toLowerCase() == "female";

    final List<Map<String, dynamic>> categories = [];

    categories.add({
      'name': 'Sweaters & Knits',
      'icon': Icons.checkroom,
      'color': const Color(0xFFB5A491),
    });

    categories.add({
      'name': 'Shirts',
      'icon': Icons.shelves,
      'color': const Color(0xFF8B7355),
    });

    categories.add({
      'name': 'T-Shirts & Casual Tops',
      'icon': Icons.dry_cleaning,
      'color': const Color(0xFFD4C4B0),
    });

    if (isFemale) {
      categories.add({
        'name': 'Blouses & Tops',
        'icon': Icons.local_mall,
        'color': const Color(0xFFB5A491),
      });
    }

    categories.add({
      'name': 'Trousers & Pants',
      'icon': Icons.safety_divider,
      'color': const Color(0xFF8B7355),
    });

    categories.add({
      'name': 'Jeans & Denim',
      'icon': Icons.workspace_premium,
      'color': const Color(0xFFD4C4B0),
    });

    categories.add({
      'name': 'Shorts',
      'icon': Icons.wb_sunny,
      'color': const Color(0xFFB5A491),
    });

    if (isFemale) {
      categories.add({
        'name': 'Skirts',
        'icon': Icons.wc,
        'color': const Color(0xFF8B7355),
      });

      categories.add({
        'name': 'Dresses',
        'icon': Icons.face_retouching_natural,
        'color': const Color(0xFFD4C4B0),
      });

      categories.add({
        'name': 'Jumpsuits & Rompers',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFB5A491),
      });
    }

    categories.add({
      'name': 'Blazers & Jackets',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFF8B7355),
    });

    categories.add({
      'name': 'Coats',
      'icon': Icons.ac_unit,
      'color': const Color(0xFFD4C4B0),
    });

    categories.add({
      'name': 'Shoes',
      'icon': Icons.directions_run,
      'color': const Color(0xFFB5A491),
    });

    categories.add({
      'name': isFemale ? 'Bags & Accessories' : 'Bags & Accessories',
      'icon': isFemale ? Icons.shopping_basket : Icons.work_outline,
      'color': const Color(0xFF8B7355),
    });

    categories.add({
      'name': 'Scarves & Ties',
      'icon': Icons.sports_martial_arts,
      'color': const Color(0xFFD4C4B0),
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Browse by Category",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              context,
              category['name'] as String,
              category['icon'] as IconData,
              category['color'] as Color,
              userProfile,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String categoryName,
    IconData icon,
    Color color,
    UserProfileModel userProfile,
  ) {
    return InkWell(
      onTap: () {
        // Use elegant transition for navigation
        context.elegantNavigateTo(
          CategoryDetailScreen(categoryName: categoryName),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                categoryName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          "Analyze Skin Tone",
          "Upload your photo to identify your undertone and get your perfect color palette.",
          userProfile.isSkinToneComplete ? "Complete" : "Start",
          userProfile.isSkinToneComplete
              ? "Update Palette"
              : "Upload to Palette",
          userProfile.isSkinToneComplete,
          onNavigateToPalette,
        ),
        const SizedBox(height: 16),
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
