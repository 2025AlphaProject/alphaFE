import 'package:alpha_fe/components/token_controller.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; //
import 'dart:convert';
import '../../components/app_bar.dart';
import 'package:alpha_fe/pages/my_page/mission_page_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mission_Page extends StatefulWidget {
  final todayPlaces;
  const Mission_Page({super.key,required this.todayPlaces});

  @override
  State<Mission_Page> createState() => _Mission_PageState();
}

class _Mission_PageState extends State<Mission_Page> {
  List<Map<String, dynamic>> _missions_ex = [];
  static final List<Map<String, dynamic>> _missions = [];

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
      }
    }
  }

  bool _isLoading = true;
  bool _hasShownDialogToday = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowDialog();
    updateMissionsWithTodayPlaces(widget.todayPlaces);
  }

  //이건 임의의 미션 생성을 위한 창으로 하루에 한번만 뜬다.
  Future<void> _checkAndShowDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final String? lastShownDate = prefs.getString('lastMissionDialogDate');

    // Early return if already shown dialog today in this session
    if (_hasShownDialogToday || lastShownDate == today) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasShownDialogToday = true; // prevent multiple dialogs in same session
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오늘의 미션 설명'),
          content: const Text('오늘의 미션 내용을 확인해보세요!'),
          actions: [
            TextButton(
              onPressed: () {
                prefs.setString('lastMissionDialogDate', today);
                _hasShownDialogToday = true; // Also prevent re-trigger after pressing 확인
                print("ok:${_missions}");
                //missionCreate();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    });
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
            //"image_url":"",
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('미션 생성이 완료되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("에러 발생: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: width * 0.1),

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
                            style: TextStyle(
                              fontSize: size * 0.15,
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

            SizedBox(height: width * 0.1),

            // ✅ 미션 카드 리스트
            Column(
              children: _missions.map((mission) {
                return _missionItem(context, mission, width);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

//각각 미션별로 정보와 페이지 넘어가는 버튼
Widget _missionItem(BuildContext context, Map<String, dynamic> mission, double width) {
  final bool isCompleted = mission['isCompleted'] ?? false;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: width * 0.02),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width * 0.95,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissionPage_2(mission: mission,), //상세페이지 넘어가기
            ),
          );
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
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      color: isCompleted ? const Color(0xFF008000) : const Color(0xFFFF0000),
                      size: width * 0.06,
                    ),
                    SizedBox(width: width * 0.02),
                    SizedBox(//미션 관련 장소명
                      width: width * 0.65,
                      child: Text(
                        "${mission['name']}",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.08, top: width * 0.01),
                  child: Text( //미션 내용
                    mission['image_url'].toString().isNotEmpty
                        ? "• 예시 사진과 유사하게 촬영하기"  //사진 O
                        : "• 원하는 미션을 골라보세요",     //사진 X
                    style: TextStyle(fontSize: width * 0.04),
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