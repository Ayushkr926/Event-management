import 'package:flutter/material.dart';

import '../Create_event/model/event_model.dart';



class EventDetailProvider extends ChangeNotifier {
  final EventModel event;

  EventDetailProvider(this.event);

  bool _aboutExpanded = false;

  bool get aboutExpanded => _aboutExpanded;

  void toggleAbout() {
    _aboutExpanded = !_aboutExpanded;
    notifyListeners();
  }
}
