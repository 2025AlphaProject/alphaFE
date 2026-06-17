import 'package:alpha_fe/services/http/mission/check_mission_complete.dart';
import 'package:alpha_fe/services/http/mission/mission_image_upload.dart';
import 'package:alpha_fe/services/http/mission/save_mission_complete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/gps.dart';
import '../../../../components/mission_gps.dart';
import '../../mission_page_1/viewModel/mission_page_1_viewModel.dart';
import '../../mission_page_2/viewModel/mission_page_2_viewModel.dart';

class MissionPage3Viewmodel extends ChangeNotifier {
  late Map<String, dynamic> mission;
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _mission_success = false;
  bool get mission_success => _mission_success;


  Future<void> initialize(BuildContext context, int index) async {
    final vm1 = context.read<MissionPage1Viewmodel>();
    final  Map<String, dynamic>? mission = vm1.getMissionByIndex(index);
    this.mission = mission!;
    await uploadMissionImage(context);
  }

  //200m 이내이면 성공
  bool isUserNearPlace(double place_mapY, double place_mapX, double user_mapY, double user_mapX) {
    double distance = LocationUtils.haversine(place_mapY, place_mapX, user_mapY, user_mapX);
    print('계산된 거리: ${distance.toStringAsFixed(2)} km');
    return distance <= 0.2;
  }

  Future<void>sendMissionEntry(BuildContext context) async {
    try {
      final response = await CheckMissionComplete(
        mission['tour_id'],
        mission['place_id'],
        mission['mission_id'],
      );
      if (response?.statusCode == 200) {
        print('✅ 미션 진입 API 성공');
        final data = response?.data;
        print(data);
        if(data['result']=="success"){
          mission['isCompleted']= true;
        }
        finalMission(context); //미션최종 저장 실행
      } else {
        print('❌ 미션 진입 API 실패: ${response?.statusCode}');
        final data = response?.data;
        print(data);
      }
    } catch (e) {
      print('$e');
    }
  }

  Future<void> finalMission(BuildContext context) async {
    final currentLocation = await _locationService.getCurrentLocation(); // "위도,경도" 형태 문자열
    final parts = currentLocation.split(',');
    final user_mapY = parts[0].replaceAll('위도:', '').trim(); //사용자
    final user_mapX = parts[1].replaceAll('경도:', '').trim();
    final place_mapX = double.parse(mission['mapX'].toString());  //여행장소
    final place_mapY = double.parse(mission['mapY'].toString());
    final isNear = isUserNearPlace(place_mapY, place_mapX, double.parse(user_mapY), double.parse(user_mapX)); //성공 계산 함수 호출
    //둘다 true면 성공
    if(isNear == true && mission['isCompleted']== true){
      _mission_success = true;
      notifyListeners();
    }
    try {
      final response = await SaveMissionComplete(
        mission['tdp_id'],
        _mission_success,
      );

      if (response?.statusCode == 201) {
        print('미션 최종결과 저장 성공');
        print(response?.data);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('$e');
    }
  }

  Future<void>uploadMissionImage(BuildContext context) async {
    final image = context.read<MissionPage2Viewmodel>().image;
    if (image == null) {
      print('❌ 이미지가 없습니다.');
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await MissionImageUpload(image.path, mission['tdp_id']);
    if (response?.statusCode == 201) {
      print('미션 이미지 업로드 성공');
      sendMissionEntry(context);
    } else {
      print('업로드 실패: ${response?.statusCode}');
      _isLoading = false;
      notifyListeners();
    }
  }
}