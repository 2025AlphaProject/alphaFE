import 'package:alpha_fe/components/token_controller.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; //
import 'dart:convert';
import '../../components/app_bar.dart';
import 'package:alpha_fe/pages/my_page/mission_page_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/custom_alert_dialog.dart';
import '../../components/auth_token_handler.dart';
import 'mission_success_page.dart';

class Mission_Page extends StatefulWidget {
  final todayPlaces;
  const Mission_Page({super.key,required this.todayPlaces});

  @override
  State<Mission_Page> createState() => _Mission_PageState();
}

class _Mission_PageState extends State<Mission_Page> {
  final List<Map<String, dynamic>> _missions = [];

  //오늘의 미션 리스트 정보 주기
  void updateMissionsWithTodayPlaces(List<Map<String, dynamic>> todayPlaces) {
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
          'mission_id': 1, //TODO: 미션확인
        });
        checkMissionComplete(place['tdp_id']).then((completed) {
          setState(() {
            final index = _missions.indexWhere((m) => m['tdp_id'] == place['tdp_id']);
            if (index != -1) {
              _missions[index]['isCompleted'] = completed;
            }
          });
        });
      }
    }
  }

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    updateMissionsWithTodayPlaces(widget.todayPlaces);
    missionCreate();
  }
  @override
  void didUpdateWidget(covariant Mission_Page oldWidget) { //변경사항있으면 update
    super.didUpdateWidget(oldWidget);
    if (widget.todayPlaces != oldWidget.todayPlaces) {
      _missions.clear();
      updateMissionsWithTodayPlaces(widget.todayPlaces);
      setState(() {});
    }
  }

  //미션 성공여부
  Future<bool> checkMissionComplete(int tdpId) async {
    final accessToken = await getAccessToken();  // 인증 토큰 가져오기
    final dio = Dio();
    final tdp_id = tdpId;

    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/mission/is_complete/$tdp_id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['mission_success'] ?? false;
      } else {
        print('❌ 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('이거🚨 예외 발생: $e');
    }
    return false;
  }

  //임의의 미션 부여하기
  Future<void> missionCreate() async{
    final accessToken = await getAccessToken();
    final dio = Dio();
    try {
      final formattedPayload = {
        "places": (widget.todayPlaces as List<dynamic>).map((place) {
          return {
            "tdp_id": place["tdp_id"],
            "image_url": place["image_url"]?.toString() ?? "",

          };
        }).toList()
      };
      print("🔍 JSON payload to be sent: ${jsonEncode(formattedPayload)}");
      final response = await dio.post(
        'http://conever.duckdns.org:8000/mission/random/',
        data: formattedPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      if (response.statusCode == 201) {
        print('[DEBUG]: 미션 로드 성공');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
      if (e is DioException && e.response?.statusCode == 403) {
        await getAccessTokenFromRefreshToken();
        await missionCreate();
        return;
      }
      print("에러 발생: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    int completed = _missions.where((m) => m['isCompleted'] == true).length;
    int total = _missions.length;
    print("ok:${_missions}"); //이건 확인용 최종때 지우면됨

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "미션 진행도"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 0.023),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.046),

            // ✅ 반응형 원형 진행률 표시
            LayoutBuilder(
              builder: (context, constraints) {
                double size = constraints.maxWidth * 0.5;
                return Center(
                  child: SizedBox(
                    height: size,
                    width: size,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: total == 0 ? 0 : completed / total,
                          strokeWidth: width * 0.05,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                        ),
                        Center(
                          child: Text(
                            '$completed/$total',
                            style: const TextStyle(
                              fontSize: 32.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: height * 0.0461),

            // ✅ 미션 카드 리스트 또는 "미션 없음" 안내
            _missions.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: height * 0.1),
                    child: Column(
                      children: [
                      Text(
                        '😯',
                        style: TextStyle(
                          fontSize: width * 0.1,
                          color: Colors.black54,
                        ),
                      ),
                        SizedBox(height: height * 0.02),
                        Text(
                          '현재 수행 가능한 미션이 없어요!',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _missions.map((mission) {
                      return _missionItem(context, mission, width, height);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

Widget _missionItem(BuildContext context, Map<String, dynamic> mission, double width, double height) {
  final bool isCompleted = mission['isCompleted'] ?? false;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: height * 0.01),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width * 0.95,
      ),
      child: GestureDetector(
        onTap: () {
          if (mission['isCompleted'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissionSuccessPage(
                  tdp_id: mission['tdp_id'],
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissionPage_2(mission: mission),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0,0),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ]
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.018),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      color: isCompleted ? const Color(0xFF008000) : const Color(0xFFFF0000),
                      size: 24.6,
                    ),
                    SizedBox(width: width * 0.02),
                    SizedBox(//미션 관련 장소명
                      width: width * 0.65,
                      child: Text(
                        "${mission['name']}",
                        style: const TextStyle(
                          fontSize: 20.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.08, top: height * 0.004),
                  child: Text( //미션 내용
                    mission['image_url'].toString().isNotEmpty
                        ? "• 예시 사진과 유사하게 촬영하기"  //사진 O
                        : "• 원하는 미션을 골라보세요",     //사진 X
                    style: const TextStyle(fontSize: 16.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
