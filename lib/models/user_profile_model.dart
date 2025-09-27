import 'package:flutter/material.dart';

class UserProfileModel extends ChangeNotifier {
  String? username;
  String? bodyType;
  String? skinUndertone;

  int _navigationIndex = 0;
  int get navigationIndex => _navigationIndex;

  void setNavigationIndex(int index) {
    print(
      '[USER] setNavigationIndex: from $_navigationIndex -> $index (isProfileComplete=$isProfileComplete, bodyType=$bodyType)',
    );
    if (_navigationIndex == index) return;
    _navigationIndex = index;
    notifyListeners();
  }

  bool get isBodyTypeComplete => bodyType != null && bodyType!.isNotEmpty;
  bool get isSkinToneComplete =>
      skinUndertone != null && skinUndertone!.isNotEmpty;
  bool get isProfileComplete => isBodyTypeComplete && isSkinToneComplete;

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

  List<String> get styleRecommendations {
    if (!isBodyTypeComplete)
      return [
        'Versatile Basics',
        'Classic Cuts',
        'Neutral Colors',
        'Timeless Pieces',
      ];

    switch (bodyType?.toLowerCase()) {
      case 'hourglass':
        return [
          'Wrap Dresses',
          'High-Waisted Jeans',
          'Fitted Blazers',
          'A-Line Skirts',
        ];
      case 'pear':
        return [
          'A-Line Tops',
          'Boat Necks',
          'Wide Leg Pants',
          'Statement Earrings',
        ];
      case 'apple':
        return [
          'Empire Waist',
          'V-Necks',
          'Straight Leg Jeans',
          'Long Cardigans',
        ];
      case 'rectangle':
        return [
          'Peplum Tops',
          'Belted Dresses',
          'Layered Looks',
          'Ruffled Blouses',
        ];
      case 'franco':
        return [
          'Tailored Jackets',
          'Structured Tops',
          'Straight Skirts',
          'Slim-fit Pants',
        ];
      default:
        return [
          'Versatile Basics',
          'Classic Cuts',
          'Neutral Colors',
          'Timeless Pieces',
        ];
    }
  }
}
