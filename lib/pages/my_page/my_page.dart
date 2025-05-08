import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:flutter/cupertino.dart';
import '../../components/auth_token_handler.dart';
import '../../components/logout_by_expiration.dart';
import '../../components/logout_by_user.dart';
import '../../components/token_controller.dart';
import '../../components/mission_loading_page.dart';
import 'mission_page.dart';
import 'my_page_Q&A.dart';
import 'package:dio/dio.dart';

class MyPage extends StatelessWidget {
  final String? accessToken;
  const MyPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이페이지"),
      body: MyPageBody(accessToken: accessToken,),
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
    final accessToken = widget.accessToken;
    final dio = Dio();

    try {
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
    } catch (e) {
      // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
      if (e is DioException && e.response?.statusCode == 403) {
        final bool? result = await getAccessTokenFromRefreshToken();
        if (result == false) {
          LogoutByExpiration(context);
        }
        await _fetchUserInfo();
        return;
      }
    }
  }

  //여행 수 표시 - [GET] 내 여행 가져오기(리스트)
  Future<void> _fetchTourCount() async {
    final accessToken = widget.accessToken;
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
  // 내여행 가져오기
  Future<void> todayTours(String username) async {
    final accessToken = widget.accessToken;
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

  //오늘의 미션 개수 가져오기
  Future<void> loadTodayPlaces() async {
    final accessToken = widget.accessToken;
    final dio = Dio();

    final todayDateString = DateTime.now().toIso8601String().substring(0, 10);

    try {
      Map<int, Map<String, dynamic>> placeMap = {};

      //여행에서 경로 불러와서 장소 수에 따라 미션 개수
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

          //오늘 여행의 경로에 포함된 장소들 정보 넣기(중복 없이) - 미션을 위해
          if (todayCourse != null) {
            final List<dynamic> places = todayCourse['places'];
            for (var place in places) {
              final placeId = place['place_id'];
              if (!placeMap.containsKey(placeId)) {
                placeMap[placeId] = {
                  'place_id': placeId,
                  'tdp_id': place['tdp_id'],
                  'image_url': place['image_url'] ?? '',
                  'date': todayDateString,
                  'name': place['name'],
                  'mapX': place['mapX'],
                  'mapY': place['mapY'],
                  'tour_id': tourId,
                };
              }
            }
          }
        }
      }
      // 값 다 반영해서 띄우기 위해
      setState(() {
        todayPlaces = placeMap.values.toList();
        print(todayPlaces);
        missionCount =  placeMap.length;
      });
    } catch (e) {
      print('Fetch today places error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); //연결 안되면 로딩뜨는거
    }

    final safeUrl = profileImageUrl?.replaceFirst('http://', 'https://') ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.042, horizontal: width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column( //이게 프로필 사진, 이름
            children: [
              SizedBox(height: height * 0.01),
              Container(
                width: width * 0.25,
                height: height  * 0.115,
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: width * 51.3,
                  backgroundImage: NetworkImage(safeUrl),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: height * 0.03),
              Text(
                username ?? '',
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 24.6,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 10, color: Color(0xFFCCCCCC))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.023),
          Row( //여행이랑 미션 수
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StateItem(tourCount.toString(), "여행", width, height),
              SizedBox(width: width * 0.08),
              _StateItem(missionCount.toString(), "미션", width, height),
            ],
          ),
          SizedBox(height: height * 0.05),
          Column( //미션진행도랑 자주묻는 질문
            children: [
              _menuItem(context, Icons.trending_up, "미션 진행도", Mission_Page(todayPlaces: todayPlaces, accessToken: widget.accessToken,), width, height),
              _menuItem(context, Icons.help_outline_outlined, "자주 묻는 질문", const MyPage_QA(), width, height),
              _menuItem(context, Icons.logout, "로그아웃", const SizedBox(), width, height, onTap: () {LogoutByUser(context);}),
            ],
          ),
        ],
      ),
    );
  }
}

//여행수랑 미션수 나타내는 위젯
Widget _StateItem(String value, String label, double width, double height) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 24.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: height * 0.002),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 12.3,
        ),
      ),
    ],
  );
}

//미션 진행도랑 자주묻는 질문 나타내는 위젯
Widget _menuItem(BuildContext context, IconData icon, String menu, Widget page, double width, double height, {VoidCallback? onTap}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: height * 0.0046),
    child: SizedBox(
      width: width * 0.75,
      child: TextButton(
        onPressed: onTap ?? () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
        },
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
          foregroundColor: const Color(0xFFCCCCCC),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.6, color: const Color(0xFF000000)),
            SizedBox(width: width * 0.02),
            Text(
              menu,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 20.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}