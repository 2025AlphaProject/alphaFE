import 'dart:io';
import 'package:alpha_fe/components/mission_loading_page.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/camera.dart';
import 'package:alpha_fe/mainscreen.dart';
import 'package:flutter/foundation.dart';
import '../../components/token_controller.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/gps.dart';
import '../../components/mission_gps.dart';

class missionTest extends StatefulWidget {
  final Map<String, dynamic> mission;
  final dynamic image;

  const missionTest({
    Key? key,
    required this.mission,
    required this.image,
  }) : super(key: key);
  @override
  State<missionTest> createState() => _missionTestState();
}

class _missionTestState extends State<missionTest> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  bool mission_success = false;

  //200m 이내이면 성공
  bool isUserNearPlace(double place_mapY, double place_mapX, double user_mapY, double user_mapX) {
    double distance = LocationUtils.haversine(place_mapY, place_mapX, user_mapY, user_mapX);
    print('계산된 거리: ${distance.toStringAsFixed(2)} km');
    return distance <= 0.2;
  }

  @override
  void initState() {
    super.initState();
    uploadMissionImage();
  }

  //미션 성공 여부 판단
  Future<void> _sendMissionEntry() async {
    final accessToken = await getAccessToken();
    final dio = Dio();

    try {

      final requestData = {
        "travel_id": widget.mission['tour_id'],
        "place_id": widget.mission['place_id'],
        "mission_id": widget.mission['mission_id'],
      };

      print('📤 미션 체크 요청 데이터: $requestData'); //확인용 코드

      final response = await dio.post(
        'http://conever.duckdns.org:8000/mission/check_complete/',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ 미션 진입 API 성공');
        final data = response.data;
        print(data);
        if(data['result']=="success"){
          widget.mission['isCompleted']= true;
        }
        finalMission(); //미션최종 저장 실행
      } else {
        print('❌ 미션 진입 API 실패: ${response.statusCode}');
        final data = response.data;
        print(data);
      }
    } catch (e) {
      print('🚨 예외 발생 (미션 진입): $e');
    }
  }

  //미션 사진 업로드
  Future<void> uploadMissionImage() async {
    final accessToken = await getAccessToken(); // 토큰 불러오기
    final dio = Dio();

    try {
      final formData = FormData.fromMap({
        'travel_days_id': widget.mission['tdp_id'].toString(),
        'image': await MultipartFile.fromFile(widget.image.path),
      });

      final response = await dio.post(
        'http://conever.duckdns.org:8000/mission/image_upload/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        print('미션 이미지 업로드 성공');
        _sendMissionEntry();

      } else {
        print('업로드 실패: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('예외 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //미션 최종 저장
  Future<void> finalMission() async{
    final accessToken = await getAccessToken();
    final dio = Dio();
    final currentLocation = await _locationService.getCurrentLocation(); // "위도,경도" 형태 문자열
    final parts = currentLocation.split(',');
    final user_mapY = parts[0].replaceAll('위도:', '').trim(); //사용자
    final user_mapX = parts[1].replaceAll('경도:', '').trim();
    final place_mapX = double.parse(widget.mission['mapX'].toString());  //여행장소
    final place_mapY = double.parse(widget.mission['mapY'].toString());
    final isNear = isUserNearPlace(place_mapY, place_mapX, double.parse(user_mapY), double.parse(user_mapX)); //성공 계산 함수 호출
    //둘다 true면 성공
    if(isNear == true && widget.mission['isCompleted']== true){
      mission_success = true;
    }

    try{
      final requestData = {
        "tdp_id": widget.mission['tdp_id'],
        "is_success": mission_success
      };

      final response = await dio.post(
        'http://conever.duckdns.org:8000/mission/save_mission_complete/',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 201) {
        print('미션 최종결과 저장 성공');
        print(response.data);
        setState(() {
          _isLoading = false;
        });
      }
    }catch (e){
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "미션 진행도"),
      body: _isLoading
          ? const MissionLoadingView() //그 완료될 떄까지 로딩페이지 띄우기
          : Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.034),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (mission_success) ...[ //성공시
                          const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          SizedBox(width: width * 0.009),
                          const Text(
                            "미션 성공!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                        if (!mission_success) ...[ //실패시
                          const Icon(Icons.cancel, color: Colors.red, size: 30),
                          SizedBox(width: width * 0.009),
                          const Text(
                            "미션 실패!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.009),
                  Text(widget.mission['image_url'].toString().isNotEmpty //미션 내용
                      ? "• 예시 사진과 유사하게 촬영하기"
                      : (widget.mission['mission_id'] == 1
                      ? "브이 포즈로 사진을 찍어보세요"
                      : (widget.mission['mission_id']  == 2
                      ? "손가락 하트를 하고 사진을 찍어보세요"
                      : '여러분이 사진에 꼭 등장해야 해요!'
                  )),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.036),
                  Container(
                    width: width * 0.72,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image.file(widget.image, fit: BoxFit.cover),
                  ),

                  SizedBox(height: height * 0.0577,),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // 배경색
                      foregroundColor: Colors.white, // 글자색
                      padding: EdgeInsets.symmetric(horizontal: width * 0.0583, vertical: height * 0.013),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    child: const Text(
                      "홈으로",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
