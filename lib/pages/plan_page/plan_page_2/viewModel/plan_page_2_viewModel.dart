import 'package:flutter/material.dart';

import '../../../../services/http/tour/fetch_tour_courses.dart';
import '../../../../services/http/tour/fetch_tours.dart';


class PlanPage2ViewModel extends ChangeNotifier {
  final int tourId;

  PlanPage2ViewModel({required this.tourId});

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
    await fetchTourCourseApi(context, tourId);
    await _precacheImages(context);
    await fetchTourNameApi(context, tourId);

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

  Future<void> fetchTourCourseApi(BuildContext context, int tourId) async {
    final List<dynamic> data = await fetchTourCourses(context, tourId);
    courseData = data.map<Map<String, dynamic>>((day) {
      final date = day['date'] ?? '';
      final places = (day['places'] as List<dynamic>? ?? []).map<Map<String, dynamic>>((place) {
        return {
          'name': place['name'] ?? '',
          'mapX': place['mapX'] != null ? place['mapX'].toDouble() : 0.0,
          'mapY': place['mapY'] != null ? place['mapY'].toDouble() : 0.0,
          'image_url': place['image_url'] ?? '',
          'road_address': place['road_address'] ?? '',
          'parcel_address': place['parcel_address'] ?? '',
        };
      }).toList();
      return {
        'date': date,
        'places': places,
      };
    }).toList();
    notifyListeners();
  }

  Future<void> fetchTourNameApi(BuildContext context, int tourId) async {
    final Map<String, dynamic> data = await fetchTours(context, tourId);
    _tourinfo = {
      'tour_name': data['tour_name'] ?? "",
      'start_date': data['start_date'] ?? "",
      'end_date': data['end_date'] ?? "",
      "travelers": (data['user'] is List)
          ? (data['user'] as List).map<Map<String, String>>((user) {
        return {
          'name': user['username'] ?? "이름 없음",
          "image_url": user['profile_image_url'] ?? "https://via.placeholder.com/150",
        };
      }).toList()
          : <Map<String, String>>[],
    };
    notifyListeners();
  }
}