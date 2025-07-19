import 'package:flutter/material.dart';

import '../../../../services/http/tour/fetch_all_tours.dart';
import '../../../../services/http/user/fetch_my_info.dart';
import '../../../home_page/home_page_view_model/plan_view_model.dart';

enum SortType { dDayAsc, dDayDesc, title }

class SortViewModel extends ChangeNotifier{
  List<Map<String, dynamic>> _cardData = [];
  bool _isLoading = true;
  SortType _sortType = SortType.dDayAsc;

  bool get isLoading => _isLoading;
  SortType get sortType => _sortType;

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
    print("sorted: $sorted");
    switch (_sortType) {
      case SortType.dDayAsc:
        sorted.sort((a, b) =>
            calculateDday(a['end_date']!).compareTo(
                calculateDday(b['end_date']!)));
        break;
      case SortType.dDayDesc:
        sorted.sort((a, b) =>
            calculateDday(b['end_date']!).compareTo(
                calculateDday(a['end_date']!)));
        break;
      case SortType.title:
        sorted.sort((a, b) => a['tour_name']!.compareTo(b['tour_name']!));
        break;
    }
    return sorted;
  }

  Future<void> fetchTours(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allTours = await fetchAllTours();
      final userInfo = await FetchMyInfo();
      final String username = userInfo['username'];
      final filtered = filterToursByUsername(allTours, username);

      final validTours = <Map<String, dynamic>>[];
      for (var plan in filtered) {
        final isValid = await isValidPlan(context: context, plan: plan);
        if (isValid) validTours.add(plan);
      }

      _cardData = validTours;
    } catch (e) {
      print("fetchTours 오류: $e");
      _cardData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getInitialPageIndex() {
    final today = DateTime.now();
    return sortedCardData.indexWhere((item) {
      final end = DateTime.parse(item['endDate']!.replaceAll('.', '-'));
      return !end.isBefore(today);
    });
  }
}