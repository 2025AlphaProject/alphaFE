import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class PlanPage2ViewModel extends ChangeNotifier {
  final String? accessToken;
  final int tourId;

  PlanPage2ViewModel({required this.accessToken, required this.tourId});

  bool isLoading = true;
  Map<String, dynamic> _tourinfo = {};
  Map<String, dynamic> get tourinfo => _tourinfo;
  List<Map<String, dynamic>> courseData = [];

  String get tourName => tourinfo['tour_name'] ?? "";
  String get startDate => tourinfo['start_date'] ?? "";
  String get endDate => tourinfo['end_date'] ?? "";

  void updateTourInfo(Map<String, dynamic> info) {
    _tourinfo = info;
    notifyListeners();
  }

  Future<void> loadInitialData(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    //TODO api 연동
    //await fetchTourCourse(context);
    await _precacheImages(context);
    //await fetchTourName(context);

    isLoading = false;
    notifyListeners();
  }


  Future<void> _precacheImages(BuildContext context) async {
    final imageUrls = courseData
        .expand((day) => day['places'] as List<Map<String, dynamic>>)
        .map((place) => place['image_url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    for (final url in imageUrls) {
      if (!context.mounted) return;
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (e) {
        print("프리캐싱 실패: $e");
      }
    }
  }

  Future<void> refreshData(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    await Future.wait([
     //TODO api 연동
    ]);
    isLoading = false;
    notifyListeners();
  }
}