import 'dart:io';
import 'package:alpha_fe/components/mission_loading_page.dart';
import 'package:dio/dio.dart';
import 'package:alpha_fe/components/camera.dart';
import 'package:alpha_fe/mainscreen.dart';
import '../../components/token_controller.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/gps.dart';

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
      final currentLocation = await _locationService.getCurrentLocation(); // "위도,경도" 형태 문자열
      final parts = currentLocation.split(',');
      final mapY = parts[0].replaceAll('위도:', '').trim();
      final mapX = parts[1].replaceAll('경도:', '').trim();

      final requestData = {
        "travel_id": widget.mission['tour_id'],
        "place_id": widget.mission['place_id'],
        "mission_id": widget.mission['mission_id'],
        "mapX": mapX.toString(),
        "mapY": mapY.toString()
        //미션 장소 성공용 테스트에 사용
        // "mapX": widget.mission['mapX'].toString(),
        // "mapY": widget.mission['mapY'].toString()
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
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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
                        if (widget.mission['isCompleted']) ...[ //성공시
                          const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          SizedBox(width: width * 0.009),
                          const Text(
                            "미션 성공!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                        if (!widget.mission['isCompleted']) ...[ //실패시
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
