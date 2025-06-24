import 'package:flutter/material.dart';

enum SortType { dDayAsc, dDayDesc, title }

class SortViewModel extends ChangeNotifier{
  List<Map<String, dynamic>> _cardData = [];
  bool _isLoading = true;
  SortType _sortType = SortType.dDayAsc;

  bool get isLoading => _isLoading;
  SortType get sortType => _sortType;

  //TODO 여행목록 받아오는 액세스 연결

  void setSortType(SortType type) {
    _sortType = type;
    notifyListeners();
  }

  void setCardData(List<Map<String, dynamic>> data) {
    _cardData = data;
    notifyListeners();
  }

  int calculateDday(String endDate) {
    final today = DateTime.now();
    final end = DateTime.parse(endDate.replaceAll('.', '-'));
    return end.difference(today).inDays;
  }

  List<Map<String, dynamic>> get sortedCardData {
    final sorted = List<Map<String, dynamic>>.from(_cardData);
    switch (_sortType) {
      case SortType.dDayAsc:
        sorted.sort((a, b) =>
            calculateDday(a['endDate']!).compareTo(
                calculateDday(b['endDate']!)));
        break;
      case SortType.dDayDesc:
        sorted.sort((a, b) =>
            calculateDday(b['endDate']!).compareTo(
                calculateDday(a['endDate']!)));
        break;
      case SortType.title:
        sorted.sort((a, b) => a['title']!.compareTo(b['title']!));
        break;
    }
    return sorted;
  }

  int getInitialPageIndex() {
    final today = DateTime.now();
    return sortedCardData.indexWhere((item) {
      final end = DateTime.parse(item['endDate']!.replaceAll('.', '-'));
      return !end.isBefore(today);
    });
  }
}