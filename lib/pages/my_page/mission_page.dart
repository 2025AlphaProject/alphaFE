import 'package:alpha_fe/components/token_controller.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; //
import '../../components/app_bar.dart';
import 'package:alpha_fe/pages/my_page/mission_page_2.dart';

class Mission_Page extends StatefulWidget {
  const Mission_Page({super.key});

  @override
  State<Mission_Page> createState() => _Mission_PageState();
}

class _Mission_PageState extends State<Mission_Page> {
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  //미션 진행도 - [GET] 미션 리스트 가져오기
  Future<void> _fetchMissions() async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/mission/list/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken', //
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _missions = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("응답 실패: ${response.statusCode}");
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "미션페이지"),
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
              builder: (context) => MissionPage_2(
                content: mission['content'],
                isCompleted: isCompleted,
              ),
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
                    Text(
                      "미션 ${mission['id']}",
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.08, top: width * 0.01),
                  child: Text(
                    "• ${mission['content']}",
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