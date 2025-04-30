import 'package:alpha_fe/components/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../components/app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "계획 앱바 영역"),
      body: const PlanPage_Body(),
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
  final String accessToken =  dotenv.env['KAKAO_ACCESS_TOKEN']!;

  SortType _sortType = SortType.dDayAsc;

  List<Map<String, dynamic>> _cardData = [];

  @override
  void initState() {
    super.initState();
    _fetchTourData();
  }

  //내 여행 가져오기(리스트)
  Future<void> _fetchTourData() async {

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
        final List<dynamic> data = response.data;
        final parsedData = data.map<Map<String, dynamic>>((item) =>
        {
          'tour_id': item['id'],
          'title': item['tour_name'],
          'startDate': item['start_date'],
          'endDate': item['end_date'],
        }).toList();

        setState(() {
          _cardData = parsedData;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cards = sortedCardData;

    return _isLoading //페이지 불러올때까지 로딩 띄우기 일단 이건 다른페이지에도 넣을 예정
        ? const Center(child: CircularProgressIndicator())
        : _cardData.isEmpty
            ? const Center(child: Text('등록된 여행이 없습니다.'))
            : Column(
      children: [
        SizedBox(height: screenWidth * 0.25),

        // 정렬 기준 드롭다운
        Container(
          height: screenWidth * 0.08,
          width: screenWidth * 0.35,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<SortType>(
            value: _sortType,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF000000),
                size: screenWidth * 0.05),
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
                      "날짜순", style: TextStyle(fontSize: screenWidth * 0.035))),
              DropdownMenuItem(value: SortType.dDayDesc,
                  child: Text(
                      "날짜역순", style: TextStyle(fontSize: screenWidth * 0.035))),
              DropdownMenuItem(value: SortType.title,
                  child: Text(
                      "제목순", style: TextStyle(fontSize: screenWidth * 0.035))),
            ],
          ),
        ),

        SizedBox(height: screenWidth * 0.05),

        // 카드 슬라이더
        SizedBox(
          height: screenWidth * 0.8,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final item = cards[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: PlanCard(
                  title: item['title']!,
                  startDate: item['startDate']!,
                  endDate: item['endDate']!,
                  size_h: screenWidth * 1.0,
                  size_w: screenWidth * 0.65,
                  tour_id: item['tour_id'],
                ),
              );
            },
          ),
        ),

        SizedBox(height: screenWidth * 0.05),

        // 페이지 인디케이터
        PlanPageIndicator(
          controller: _pageController,
          count: cards.length,
          dotSize: screenWidth * 0.02,
          dotActiveWidth: screenWidth * 0.03,
        ),
      ],
    );
  }
}

//페이지 인디케이터
class PlanPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;
  final double dotSize;
  final double dotActiveWidth;

  const PlanPageIndicator({
    Key? key,
    required this.controller,
    required this.count,
    this.dotSize = 8.0,
    this.dotActiveWidth = 12.0,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final dotSize = screenWidth * 0.02;
    final dotActiveWidth = screenWidth * 0.03;

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