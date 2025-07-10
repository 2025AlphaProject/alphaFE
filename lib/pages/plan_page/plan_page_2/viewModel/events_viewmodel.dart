import 'package:alpha_fe/services/http/events/fetch_events.dart';
import 'package:flutter/foundation.dart';

class EventsViewModel extends ChangeNotifier{
  final double mapX;
  final double mapY;

  bool _isLoading = false;
  dynamic _result;

  EventsViewModel({required this.mapX, required this.mapY});

  bool get isLoading => _isLoading;
  dynamic get result => _result;

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    _result = fetchEventsFromApi(mapX, mapY);
    _isLoading = false;
    notifyListeners();
  }
}