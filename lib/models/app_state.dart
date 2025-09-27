import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _skinUndertone;

  String? get skinUndertone => _skinUndertone;

  void updateSkinUndertone(String undertone) {
    _skinUndertone = undertone;
    notifyListeners();
  }
}
