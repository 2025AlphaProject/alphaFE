import 'package:alpha_fe/components/plan_card.dart';
import 'package:alpha_fe/components/token_controller.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import '../../components/auth_token_handler.dart';


// 전역 상태 관리 클래스
class EditState {
  static bool showEditButton = false;
}

class PlanPage extends StatelessWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: DefaultAppBar(title: "나의 계획"),
      body: PlanPage_Body(),
    );
  }
}

class PlanPage_Body extends StatefulWidget {
  const PlanPage_Body({Key? key}) : super(key: key);

  @override
  State<PlanPage_Body> createState() => _PlanPage_BodyState();
}

enum SortType { dDayAsc, dDayDesc, title }

class _PlanPage_BodyState extends State<PlanPage_Body> {
  late PageController _pageController;
  late int initialPage;
  bool _isLoading = true;

  SortType _sortType = SortType.dDayAsc;

  List<Map<String, dynamic>> _cardData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTourData();
  }

  //내 여행 가져오기(리스트)
  Future<void> _fetchTourData() async {
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

      // Fetch the current user
      String? currentUsername;
      try {
        final userResponse = await dio.get(
          'http://conever.duckdns.org:8000/user/me/',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json'
            },
          ),
        );
        if (userResponse.statusCode == 200) {
          currentUsername = userResponse.data['username'];
        }
      } catch (e) {
        // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
        if (e is DioException && e.response?.statusCode == 403) {
          await getAccessTokenFromRefreshToken();
          await _fetchTourData();
          return;
        }

        // If fetching user fails, show error and stop loading
        setState(() {
          _isLoading = false;
        });
        print('Fetch user error: $e');
        return;
      }

      if (response.statusCode == 200 && currentUsername != null) {
        final List<dynamic> allPlans = response.data;
        final List<dynamic> userPlans = allPlans.where((plan) {
          final List<dynamic> users = plan['user'] ?? [];
          return users.any((u) => u['username'] == currentUsername);
        }).toList();

        final parsedData = userPlans.map<Map<String, dynamic>>((item) => {
          'tour_id': item['id'],
          'title': item['tour_name'],
          'startDate': item['start_date'],
          'endDate': item['end_date'],
        }).toList();

        // 불필요한 여행 삭제: 코스가 없는 경우
        final List<int> deletedTourIds = [];

        for (final plan in parsedData) {
          final dynamic tourIdRaw = plan['tour_id'];
          final int? tourId = tourIdRaw is int ? tourIdRaw : int.tryParse(tourIdRaw.toString());

          if (tourId == null) {
            print('Invalid tour_id: $tourIdRaw');
            continue;
          }

          try {
            final courseResponse = await dio.get(
              'http://conever.duckdns.org:8000/tour/course/$tourId/',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json',
                },
              ),
            );

            if (courseResponse.statusCode == 200 &&
                courseResponse.data is Map &&
                courseResponse.data['courses'] is List &&
                (courseResponse.data['courses'] as List).isEmpty) {
              await dio.delete(
                'http://conever.duckdns.org:8000/tour/$tourId/',
                options: Options(
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                    'Content-Type': 'application/json',
                  },
                ),
              );
              deletedTourIds.add(tourId);
            }
          } catch (e) {
            print('Error checking or deleting tour $tourIdRaw: $e');
          }
        }

        // 삭제된 여행 제외
        final filteredData = parsedData.where((plan) {
          final tourId = int.tryParse(plan['tour_id'].toString()) ?? -1;
          return !deletedTourIds.contains(tourId);
        }).toList();

        setState(() {
          _cardData = filteredData;
          _isLoading = false;
          if (_cardData.isNotEmpty) {
            _initController();
          }
        });

        setState(() {
          _cardData = filteredData;
          _isLoading = false;
          if (_cardData.isNotEmpty) {
            _initController();
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Fetch error: $e');
    }
  }

  //기준별 정렬 관련들
  void _initController() {
    final today = DateTime.now();
    final index = sortedCardData.indexWhere((item) {
      final end = DateTime.parse(item['endDate']!.replaceAll('.', '-'));
      return !end.isBefore(today);
    });
    initialPage = index != -1 ? index : 0;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialPage,
    );
  }

  //날짜 계산
  int calculateDday(String endDate) {
    final today = DateTime.now();
    final end = DateTime.parse(endDate.replaceAll('.', '-'));
    return end
        .difference(today)
        .inDays;
  }
  //정렬관련
  List<Map<String, dynamic>> get sortedCardData {
    final sorted = List<Map<String, dynamic>>.from(_cardData);
    switch (_sortType) {
      case SortType.dDayAsc:
        sorted.sort((a, b) =>
            calculateDday(a['endDate']!).compareTo(
                calculateDday(b['endDate']!)));
        break;
      case SortType.dDayDesc:
        sorted.sort((a, b) =>
            calculateDday(b['endDate']!).compareTo(
                calculateDday(a['endDate']!)));
        break;
      case SortType.title:
        sorted.sort((a, b) => a['title']!.compareTo(b['title']!));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cards = sortedCardData;

    return _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _cardData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('등록된 여행이 없습니다.',
                        style: TextStyle(
                            fontSize: width * 0.045)),
                    Text('여행을 추가해주세요!',
                        style: TextStyle(
                            fontSize: width * 0.06,
                          fontWeight: FontWeight.bold
                        ),
                    ),
                  ],
                ))
            : Column(
      children: [
        SizedBox(height: height * 0.12),

        // 정렬 기준 드롭다운
        Container(
          height: height * 0.06,
          width: width * 0.35,
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(width * 0.03),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<SortType>(
            value: _sortType,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF000000),
                size: width * 0.05),
            dropdownColor: Colors.white,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortType = value;
                  _initController();
                });
              }
            },
            items: [
              DropdownMenuItem(value: SortType.dDayAsc,
                  child: Text(
                      "날짜순", style: TextStyle(fontSize: width * 0.035))),
              DropdownMenuItem(value: SortType.dDayDesc,
                  child: Text(
                      "날짜역순", style: TextStyle(fontSize: width * 0.035))),
              DropdownMenuItem(value: SortType.title,
                  child: Text(
                      "제목순", style: TextStyle(fontSize: width * 0.035))),
            ],
          ),
        ),

        SizedBox(height: height * 0.03),

        // 카드 슬라이더
        SizedBox(
          height: height * 0.4,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final item = cards[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: PlanCard(
                  title: item['title']!,
                  startDate: item['startDate']!,
                  endDate: item['endDate']!,
                  size_h: height * 0.5,
                  size_w: width * 0.65,
                  tour_id: item['tour_id'],
                ),
              );
            },
          ),
        ),

        SizedBox(height: height * 0.03),

        // 페이지 인디케이터
        PlanPageIndicator(
          controller: _pageController,
          count: cards.length,
          dotSize: width * 0.02,
          dotActiveWidth: width * 0.03,
        ),
      ],
    );
  }
}

//페이지 인디케이터
class PlanPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;
  final double? dotSize;
  final double? dotActiveWidth;

  const PlanPageIndicator({
    Key? key,
    required this.controller,
    required this.count,
    this.dotSize,
    this.dotActiveWidth,
  }) : super(key: key);

  @override
  State<PlanPageIndicator> createState() => _PlanPageIndicatorState();
}

class _PlanPageIndicatorState extends State<PlanPageIndicator> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.initialPage;
    widget.controller.addListener(_pageListener);
  }

  void _pageListener() {
    final newPage = widget.controller.page?.round() ?? 0;
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dotSize = widget.dotSize ?? width * 0.02;
    final dotActiveWidth = widget.dotActiveWidth ?? width * 0.03;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: dotSize * 0.3),
          width: isActive ? dotActiveWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? Colors.black87 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(dotSize * 0.5),
          ),
        );
      }),
    );
  }
}