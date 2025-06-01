import 'package:flutter/material.dart';
import '../../../../services/dio/authorized_dio.dart';

class MyPageViewmodel extends ChangeNotifier{
  String username ='알 수 없음';
  String profileImageUrl='';
  bool _isLoading = true;
  int tourCount = 0;
  int missionCount = 0;
  List<Map<String, dynamic>> _cardData = [];
  List<Map<String, dynamic>> todayPlaces = [];
  Map<String, dynamic> formattedTodayPlaces = {};

  String get getUsername => username;
  int get getTourCount => tourCount;
  int get getMissionCount => missionCount;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get cardData => _cardData;
  Map<String, dynamic> get todayPlacesFormatted => formattedTodayPlaces;

  Future<void> initialize(BuildContext context) async {
    await fetchTourCount(context);
    await fetchUserInfo(context);
  }


  //프로필 사진 및 이름 - [GET] 유저 정보 가져오기
  Future<void> fetchUserInfo(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    try {
      final response = await dio.get('http://conever.duckdns.org:8000/user/me/');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        username = data['username'];
        profileImageUrl = data['profile_image_url'];
        notifyListeners();
        await todayTours(context, username).then((_) => this.loadTodayPlaces(context));
        _isLoading = false;
      } else {
        print('⚠️ 예상한 JSON 형식이 아닙니다: $data');
      }
    } catch (e) {
      print('여행 리스트 불러오기 실패: $e');
    }
  }

  //여행 수 표시 - [GET] 내 여행 가져오기(리스트)
  Future<void> fetchTourCount(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/',
      );

      if (response.statusCode == 200 && username != null) {
        final List<dynamic> allTours = response.data;
        final userTours = allTours.where((tour) {
          final List<dynamic> users = tour['user'] ?? [];
          return users.any((u) => u['username'] == username);
        }).toList();

        tourCount = userTours.length;
        notifyListeners();
      }
    } catch (e) {
      print('여행 리스트 불러오기 실패: $e');
    }
  }

  // 내여행 가져오기
  Future<void> todayTours(BuildContext context, String username) async {
    final dio = await getAuthorizedDio(context);
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> allPlans = response.data;
        final List<dynamic> userPlans = allPlans.where((plan) {
          final List<dynamic> users = plan['user'] ?? [];
          return users.any((u) => u['username'] == username);
        }).toList();

        final today = DateTime.now();
        final filteredPlans = userPlans.where((plan) {
          final startDate = DateTime.tryParse(plan['start_date']);
          final endDate = DateTime.tryParse(plan['end_date']);
          return startDate != null &&
              endDate != null &&
              today.isAfter(startDate.subtract(const Duration(days: 1))) &&
              today.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();

        _cardData = filteredPlans
            .map<Map<String, dynamic>>((plan) => {
          'title': plan['tour_name'],
          'tour_id': plan['id'],
        })
            .toList()
            .cast<Map<String, dynamic>>();
        notifyListeners();
      }
    } catch (e) {
      notifyListeners();
      print('Fetch tour error: $e');
    }
  }

  //오늘의 미션 개수 가져오기
  Future<void> loadTodayPlaces(BuildContext context) async {
    final dio = await getAuthorizedDio(context);

    final todayDateString = DateTime.now().toIso8601String().substring(0, 10);

    try {
      Map<int, Map<String, dynamic>> placeMap = {};

      //여행에서 경로 불러와서 장소 수에 따라 미션 개수
      for (var tour in _cardData) {
        final tourId = tour['tour_id'];
        final response = await dio.get(
          'http://conever.duckdns.org:8000/tour/course/$tourId/',
        );

        if (response.statusCode == 200) {
          final data = response.data;
          List<dynamic> courseData;

          if (data is List) {
            courseData = data;
          } else if (data is Map<String, dynamic>) {
            courseData = [data]; // wrap into list
          } else {
            throw Exception('Unexpected data format: ${data.runtimeType}');
          }

          final todayCourse = courseData.firstWhere(
                (day) => day['date'] == todayDateString,
            orElse: () => null,
          );

          //오늘 여행의 경로에 포함된 장소들 정보 넣기(중복 없이) - 미션을 위해
          if (todayCourse != null) {
            final List<dynamic> places = todayCourse['places'];
            for (var place in places) {
              final placeId = place['place_id'];
              if (!placeMap.containsKey(placeId)) {
                placeMap[placeId] = {
                  'place_id': placeId,
                  'tdp_id': place['tdp_id'],
                  'image_url': place['image_url'] ?? '',
                  'date': todayDateString,
                  'name': place['name'],
                  'mapX': place['mapX'],
                  'mapY': place['mapY'],
                  'tour_id': tourId,
                };
              }
            }
          }
        }
      }
      // 값 다 반영해서 띄우기 위해
      todayPlaces = placeMap.values.toList();
      print(todayPlaces);
      missionCount =  placeMap.length;
      notifyListeners();
    } catch (e) {
      print('Fetch today places error: $e');
    }
  }



}