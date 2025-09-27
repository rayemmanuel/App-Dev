// lib/models/user_profile_model.dart
import 'package:flutter/material.dart';

class UserProfileModel extends ChangeNotifier {
  String? username;
  String? gender; // Added for recommendation system
  String? bodyType;
  String? skinUndertone;

  int _navigationIndex = 0;
  int get navigationIndex => _navigationIndex;

  // -------------------
  // Navigation
  // -------------------
  void setNavigationIndex(int index) {
    print(
      '[USER] setNavigationIndex: from $_navigationIndex -> $index (isProfileComplete=$isProfileComplete, bodyType=$bodyType)',
    );
    if (_navigationIndex == index) return;
    _navigationIndex = index;
    notifyListeners();
  }

  // -------------------
  // Completeness Checks
  // -------------------
  bool get isBodyTypeComplete => bodyType != null && bodyType!.isNotEmpty;
  bool get isSkinToneComplete =>
      skinUndertone != null && skinUndertone!.isNotEmpty;
  bool get isProfileComplete => isBodyTypeComplete && isSkinToneComplete;

  // -------------------
  // Updaters
  // -------------------
  void updateUsername(String name) {
    username = name;
    notifyListeners();
  }

  void updateGender(String g) {
    gender = g;
    notifyListeners();
  }

  void updateBodyType(String? type) {
    bodyType = type;
    _navigationIndex = 2;
    print('[USER] updateBodyType -> $type');
    notifyListeners();
  }

  void updateSkinTone(String tone) {
    skinUndertone = tone;
    notifyListeners();
  }

  void setSkinUndertone(String tone) => updateSkinTone(tone);

  // -------------------
  // Color Palette
  // -------------------
  List<Color> get colorPalette {
    if (!isSkinToneComplete) return [];
    switch (skinUndertone?.toLowerCase()) {
      case 'warm':
        return [
          const Color(0xFFD4AF37),
          const Color(0xFFCD853F),
          const Color(0xFFDAA520),
          const Color(0xFFB8860B),
          const Color(0xFFFF6347),
        ];
      case 'cool':
        return [
          const Color(0xFF4169E1),
          const Color(0xFF8A2BE2),
          const Color(0xFF20B2AA),
          const Color(0xFF9370DB),
          const Color(0xFF008B8B),
        ];
      default:
        return [
          const Color(0xFF708090),
          const Color(0xFF2E8B57),
          const Color(0xFF800080),
          const Color(0xFFB22222),
          const Color(0xFF4682B4),
        ];
    }
  }

  // -------------------
  // FULL Recommendation System
  // -------------------
  Map<String, List<String>> get styleRecommendations {
    if (gender == null || bodyType == null || skinUndertone == null) {
      return {
        "General": ["Please complete your profile for full recommendations."],
      };
    }

    final recs = <String, List<String>>{};

    // Body Type & Gender Mapping
    if (gender == "Female") {
      switch (bodyType?.toLowerCase()) {
        case "hourglass":
          recs["Body Shape"] = [
            "Wrap dresses, fitted blouses, high-waist skirts",
            "Emphasize waist with belts",
          ];
          break;
        case "pear":
          recs["Body Shape"] = [
            "Boat necks, off-shoulder tops, A-line skirts",
            "Dark slim trousers to balance hips",
          ];
          break;
        case "rectangle":
          recs["Body Shape"] = [
            "Peplum tops, belted dresses, ruffles",
            "Fit-and-flare silhouettes to add curves",
          ];
          break;
        case "apple":
          recs["Body Shape"] = [
            "Empire waist dresses, V-necks, long cardigans",
            "Straight-leg trousers for vertical flow",
          ];
          break;
        default:
          recs["Body Shape"] = ["Choose outfits that highlight proportions"];
      }
    } else if (gender == "Male") {
      switch (bodyType?.toLowerCase()) {
        case "ectomorph":
          recs["Body Shape"] = [
            "Layer clothing to add bulk",
            "Horizontal patterns, structured jackets",
          ];
          break;
        case "mesomorph":
          recs["Body Shape"] = [
            "Fitted shirts (not tight)",
            "Tapered trousers, blazers with defined waist",
          ];
          break;
        case "endomorph":
          recs["Body Shape"] = [
            "Dark vertical patterns, longline jackets",
            "Mid-rise straight trousers",
          ];
          break;
        default:
          recs["Body Shape"] = ["Pick tailored fits that enhance proportions"];
      }
    }

    // Undertone Clothing Database (your full lists)
    final clothing = {
      "Tops": {
        "warm": [
          "Mustard, olive, terracotta sweaters",
          "Camel button-downs, warm ivory blouses",
          "Burnt orange knits, warm red polos",
        ],
        "cool": [
          "Teal, navy, berry tops",
          "Crisp white, lavender blouses",
          "Chambray shirts, icy blue oxfords",
        ],
        "neutral": [
          "Soft taupe, denim, oatmeal sweaters",
          "Classic white tees, off-white blouses",
        ],
      },
      "Bottoms": {
        "warm": ["Camel trousers", "Rust chinos", "Terracotta shorts"],
        "cool": ["Charcoal trousers", "Slate chinos", "Teal shorts"],
        "neutral": ["Taupe trousers", "Beige chinos", "Denim shorts"],
      },
      "Dresses & Jumpsuits": {
        "warm": ["Coral wrap dress", "Honey maxi dress", "Bronze gowns"],
        "cool": ["Sapphire day dress", "Teal maxi", "Emerald gowns"],
        "neutral": [
          "Blush beige dress",
          "Muted navy maxi",
          "Classic black dress",
        ],
      },
      "Outerwear": {
        "warm": ["Camel coats", "Olive parkas", "Brown leather jackets"],
        "cool": ["Charcoal coats", "Navy pea coats", "Black leather jackets"],
        "neutral": ["Stone trench", "Beige wool coats", "Gray blazers"],
      },
      "Shoes": {
        "warm": ["Cognac loafers", "Gold sandals"],
        "cool": ["Black dress shoes", "Silver sandals"],
        "neutral": ["Taupe loafers", "Nude sandals"],
      },
      "Accessories": {
        "warm": ["Gold jewelry, tan handbags"],
        "cool": ["Silver jewelry, navy handbags"],
        "neutral": ["Both gold & silver depending on outfit"],
      },
    };

    final tone = skinUndertone?.toLowerCase() ?? "neutral";
    clothing.forEach((category, options) {
      recs[category] = options[tone] ?? [];
    });

    return recs;
  }
}
