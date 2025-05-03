import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:flutter/cupertino.dart';
import '../../components/logout_by_user.dart';
import '../../components/token_controller.dart';
import '../../components/mission_manager.dart';
import 'mission_page.dart';
import 'my_page_Q&A.dart';
import 'package:dio/dio.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이 앱바 영역"),
      body: MyPageBody(),
    );
  }
}

class MyPageBody extends StatefulWidget {
  const MyPageBody({super.key});

  @override
  State<MyPageBody> createState() => _MyPageBodyState();
}

class _MyPageBodyState extends State<MyPageBody> {
  String? username;
  String? profileImageUrl;
  bool _isLoading = true;
  int tourCount = 0;
  int missionCount = 0;
  List<Map<String, dynamic>> _cardData = [];
  List<Map<String, dynamic>> todayPlaces = [];
  Map<String, dynamic> formattedTodayPlaces = {};

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchTourCount();
    // _fetchMissionCount();
  }

  //프로필 사진 및 이름 - [GET] 유저 정보 가져오기
  Future<void> _fetchUserInfo() async {
    final accessToken = await getAccessToken();
    final dio = Dio();

    final response = await dio.get(
      'http://conever.duckdns.org:8000/user/me/',
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
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
      await todayTours(username!).then((_) => this.loadTodayPlaces());
    } else {
      print('⚠️ 예상한 JSON 형식이 아닙니다: $data');
    }
  }

  //여행 수 표시 - [GET] 내 여행 가져오기(리스트)
  Future<void> _fetchTourCount() async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 && username != null) {
        final List<dynamic> allTours = response.data;
        final userTours = allTours.where((tour) {
          final List<dynamic> users = tour['user'] ?? [];
          return users.any((u) => u['username'] == username);
        }).toList();

        setState(() {
          tourCount = userTours.length;
        });
      }
    } catch (e) {
      print('여행 리스트 불러오기 실패: $e');
    }
  }

  Future<void> todayTours(String username) async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    try {
      final response = await dio.get(
        'http://conever.duckdns.org:8000/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
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

        setState(() {
          _cardData = filteredPlans
              .map<Map<String, dynamic>>((plan) => {
                'title': plan['tour_name'],
                'tour_id': plan['id'],
              })
              .toList()
              .cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Fetch tour error: $e');
    }
  }

  Future<void> loadTodayPlaces() async {
    final accessToken = await getAccessToken();
    final dio = Dio();

    final todayDateString = DateTime.now().toIso8601String().substring(0, 10);

    try {
      List<Map<String, dynamic>> results = [];

      for (var tour in _cardData) {
        final tourId = tour['tour_id'];
        final response = await dio.get(
          'http://conever.duckdns.org:8000/tour/course/$tourId/',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
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

          if (todayCourse != null) {
            final List<dynamic> places = todayCourse['places'];
            for (var place in places) {
              final placeId = place['place_id'];
              if (!results.any((existing) => existing['place_id'] == placeId)) {
                results.add({
                  'place_id': placeId,
                  'image_url': place['image_url'] ?? '',
                  'date': todayDateString,
                  'name': place['name']
                });
              }
            }
          }
        }
      }
      setState(() {
        todayPlaces = results;
        formattedTodayPlaces = {
          "places": results.map((e) => {
            "place_id": e["place_id"],
            "image_url": e["image_url"],
            "date": e["date"]
          }).toList(),
        };
        print(formattedTodayPlaces);
        missionCount = results.map((e) => e['place_id']).toSet().length;
      });
    } catch (e) {
      print('Fetch today places error: $e');
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
              _menuItem(context, Icons.trending_up, "미션 진행도", const Mission_Page(), width),
              _menuItem(context, Icons.help_outline_outlined, "자주 묻는 질문", const MyPage_QA(), width),
              _menuItem(context, Icons.logout, "로그아웃", const SizedBox(), width, onTap: () {LogoutByUser(context);}),
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
Widget _menuItem(BuildContext context, IconData icon, String menu, Widget page, double width, {VoidCallback? onTap}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: width * 0.01),
    child: SizedBox(
      width: width * 0.75,
      child: TextButton(
        onPressed: onTap ?? () {
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