import 'package:flutter/material.dart';
import '../../../../services/http/mission/is_mission_complete.dart';
import '../../../../services/http/mission/create_mission.dart';

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
    await CreateMissionService(context, todayPlaces);
    updateMissionsWithTodayPlaces(context, todayPlaces);
  }

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

        CheckMissionService(context, place['tdp_id']).then((completed) {
          final index = _missions.indexWhere((m) => m['tdp_id'] == place['tdp_id']);
          if (index != -1) {
            _missions[index]['isCompleted'] = completed;
            notifyListeners();
          }
        });
      }
    }
    _isLoading = false;
    notifyListeners();
  }
}