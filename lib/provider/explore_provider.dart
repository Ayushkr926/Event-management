import 'package:flutter/material.dart';

class ExploreProvider extends ChangeNotifier {
  String selectedFilter = 'Discover';
  String selectedPopular = 'Concerts';

  void selectFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  void selectPopular(String value) {
    selectedPopular = value;
    notifyListeners();
  }
}
