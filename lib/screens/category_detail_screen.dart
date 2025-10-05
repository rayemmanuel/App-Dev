// lib/screens/category_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/user_profile_model.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileModel>(context);
    final recommendations = userProfile.styleRecommendations;
    final items = recommendations[categoryName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE7DFD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7DFD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB5A491), Color(0xFF8B7355)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Curated for ${userProfile.skinUndertone} undertone",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${items.length} items recommended",
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pinterest-style Masonry Grid
                Expanded(
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final itemName = items[index];
                      final clothingItem = userProfile.getClothingItem(
                        categoryName,
                        itemName,
                      );
                      return _buildPinterestCard(
                        context,
                        userProfile,
                        categoryName,
                        itemName,
                        clothingItem,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPinterestCard(
    BuildContext context,
    UserProfileModel userProfile,
    String categoryName,
    String itemName,
    ClothingItem clothingItem,
    int index,
  ) {
    final heights = [200.0, 250.0, 180.0, 220.0, 240.0, 190.0];
    final imageHeight = heights[index % heights.length];

    return GestureDetector(
      onTap: () {
        // Future: Navigate to detail view
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: _getPlaceholderColor(itemName),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: clothingItem.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(clothingItem.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: clothingItem.imageUrl == null
                      ? Center(
                          child: Icon(
                            _getIconForItem(itemName),
                            size: 48,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      : null,
                ),
                // Item name overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      itemName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        userProfile.selectOutfitItem(categoryName, itemName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "$itemName added to Your Perfect Outfit",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7355).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Perfect Match",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B7355),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Color _getPlaceholderColor(String itemName) {
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

  IconData _getIconForItem(String itemName) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.black.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              "No items found",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find any items in this category for your profile.",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
