import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'mission_page.dart';
import 'my_page_Q&A.dart';
import 'package:dio/dio.dart';

class MyPage extends StatelessWidget {
  final String? accessToken;
  const MyPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이 앱바 영역"),
      body: MyPageBody(accessToken: accessToken),
    );
  }
}

class MyPageBody extends StatefulWidget {
  final String? accessToken;
  const MyPageBody({super.key, required this.accessToken});

  @override
  State<MyPageBody> createState() => _MyPageBodyState();
}

class _MyPageBodyState extends State<MyPageBody> {
  String? username;
  String? profileImageUrl;
  bool _isLoading = true;
  int tourCount = 0;
  int missionCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchTourCount();
    _fetchMissionCount();
  }

  //프로필 사진 및 이름 - [GET] 유저 정보 가져오기
  Future<void> _fetchUserInfo() async {
    final dio = Dio();

    final response = await dio.get(
      'http://conever.duckdns.org:8000/user/me/',
      options: Options(headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      }),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      setState(() {
        username = data['username'];
        profileImageUrl = data['profile_image_url'];
        _isLoading = false;
      });
    } else {
      print('⚠️ 예상한 JSON 형식이 아닙니다: $data');
    }
  }

  //여행 수 표시 - [GET] 내 여행 가져오기(리스트)
  Future<void> _fetchTourCount() async {
    final dio = Dio();
    try {
    final response = await dio.get(
      'http://conever.duckdns.org:8000/tour/',
      options: Options(headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      }),
    );
      setState(() {
        tourCount = response.data.length;
      });
    } catch (e) {
      print('여행 리스트 불러오기 실패: $e');
    }
  }

  //미션 수 표시 - [GET] 미션 리스트 가져오기
  Future<void> _fetchMissionCount() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/mission/list/',
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        }),
      );
      setState(() {
        missionCount = response.data.length;
      });
    } catch (e) {
      print('미션 리스트 불러오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); //연결 안되면 로딩뜨는거
    }

    final safeUrl = profileImageUrl?.replaceFirst('http://', 'https://') ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.02, horizontal: width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column( //이게 프로필 사진, 이름
            children: [
              SizedBox(height: width * 0.05),
              Container(
                width: width * 0.25,
                height: width * 0.25,
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: width * 0.125,
                  backgroundImage: NetworkImage(safeUrl),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: width * 0.01),
              Text(
                username ?? '',
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 10, color: Color(0xFFCCCCCC))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.05),
          Row( //여행이랑 미션 수
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StateItem(tourCount.toString(), "여행", width),
              SizedBox(width: width * 0.08),
              _StateItem(missionCount.toString(), "미션", width),
            ],
          ),
          SizedBox(height: width * 0.12),
          Column( //미션진행도랑 자주묻는 질문
            children: [
              _menuItem(context, Icons.trending_up, "미션 진행도", Mission_Page(
                accessToken: widget.accessToken,
              ), width),
              _menuItem(context, Icons.help_outline_outlined, "자주 묻는 질문", MyPage_QA(), width),
            ],
          ),
        ],
      ),
    );
  }
}

//여행수랑 미션수 나타내는 위젯
Widget _StateItem(String value, String label, double width) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: width * 0.06,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: width * 0.02),
      Text(
        label,
        style: TextStyle(
          color: Color(0xFF757575),
          fontSize: width * 0.03,
        ),
      ),
    ],
  );
}

//미션 진행도랑 자주묻는 질문 나타내는 위젯
Widget _menuItem(BuildContext context, IconData icon, String menu, Widget page, double width) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: width * 0.01),
    child: SizedBox(
      width: width * 0.75,
      child: TextButton(
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
        },
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
          foregroundColor: Color(0xFFCCCCCC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          children: [
            Icon(icon, size: width * 0.045, color: Color(0xFF000000)),
            SizedBox(width: width * 0.02),
            Text(
              menu,
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}