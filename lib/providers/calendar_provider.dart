import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_selectedDate.year != normalizedDate.year ||
        _selectedDate.month != normalizedDate.month ||
        _selectedDate.day != normalizedDate.day) {
      _selectedDate = normalizedDate;
      notifyListeners();
    }
  }
}
