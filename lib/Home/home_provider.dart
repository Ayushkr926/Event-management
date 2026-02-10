import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  bool _isLike = false;

  bool get isLike => _isLike;

  void toggleLike() {
    _isLike = !_isLike;
    notifyListeners();
  }

  void selectCategory(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
