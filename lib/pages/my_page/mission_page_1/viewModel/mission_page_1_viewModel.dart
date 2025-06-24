import 'package:flutter/material.dart';
import '../../../../services/dio/authorized_dio.dart';

class MissionPage1Viewmodel extends ChangeNotifier {
  final List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  int get completed => _missions.where((m) => m['isCompleted'] == true).length;
  int get total => _missions.length;

  List<MapEntry<int, Map<String, dynamic>>> get missions =>
      _missions.asMap().entries.toList();
  Map<String, dynamic>? getMissionByIndex(int index) {
    if (index >= 0 && index < _missions.length) {
      return _missions[index];
    }
    return null;
  }

  Future<void> initialize(BuildContext context, List<Map<String, dynamic>> todayPlaces) async {
    await missionCreate(context, todayPlaces);
    updateMissionsWithTodayPlaces(context, todayPlaces);
  }

  //미션 성공여부
  Future<bool> checkMissionComplete(BuildContext context, int tdpId) async {
    try {
      final dio = await getAuthorizedDio(context);
      final response = await dio.get('http://conever.duckdns.org:8000/mission/is_complete/$tdpId');
      if (response.statusCode == 200) {
        return response.data['mission_success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  //오늘의 미션 리스트 정보 주기
  void updateMissionsWithTodayPlaces(BuildContext context, List<Map<String, dynamic>> todayPlaces) {
    for (var place in todayPlaces) {
      final exists = _missions.any((m) => m['tdp_id'] == place['tdp_id']);
      if (!exists) {
        _missions.add({
          'tdp_id': place['tdp_id'],
          'place_id': place['place_id'],
          'image_url': place['image_url'],
          'mapX': place['mapX'],
          'mapY': place['mapY'],
          'tour_id': place['tour_id'],
          'date': place['date'],
          'name': place['name'].replaceAll(RegExp(r'[<>]'), ''),
          'isCompleted': false,
          'mission_id': 1, // TODO: 실제 미션 ID 적용 필요
        });

        checkMissionComplete(context, place['tdp_id']).then((completed) {
          final index = _missions.indexWhere((m) => m['tdp_id'] == place['tdp_id']);
          if (index != -1) {
            _missions[index]['isCompleted'] = completed;
            notifyListeners();
          }
        });
      }
    }
    notifyListeners();
  }

  // 임의의 미션 부여하기
  Future<void> missionCreate(BuildContext context, List<Map<String, dynamic>> todayPlaces) async {
    final dio = await getAuthorizedDio(context);
    try {
      final formattedPayload = {
        "places": todayPlaces.map((place) {
          return {
            "tdp_id": place["tdp_id"],
            "image_url": place["image_url"]?.toString() ?? "",
          };
        }).toList()
      };
      final response = await dio.post(
        'http://conever.duckdns.org:8000/mission/random/',
        data: formattedPayload,
      );
      if (response.statusCode == 201) {
        debugPrint('[DEBUG]: 미션 로드 성공');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("에러 발생: $e");
    }
  }

}
