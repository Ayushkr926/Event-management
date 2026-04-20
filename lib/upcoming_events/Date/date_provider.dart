import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth =
  DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;

  List<DateTime> get daysInMonth {
    final lastDay =
    DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    return List.generate(
      lastDay.day,
          (index) =>
          DateTime(_currentMonth.year, _currentMonth.month, index + 1),
    );
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void changeMonth(int value) {
    _currentMonth =
        DateTime(_currentMonth.year, _currentMonth.month + value);
    notifyListeners();
  }
}
