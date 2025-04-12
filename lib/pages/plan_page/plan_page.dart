import 'package:alpha_fe/components/plan_card.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

// 📌 계획 페이지 메인
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

//계획 페이지 바디
class PlanPage_Body extends StatefulWidget {
  const PlanPage_Body({Key? key}) : super(key: key);

  @override
  State<PlanPage_Body> createState() => _PlanPage_BodyState();
}

enum SortType { dDayAsc, dDayDesc, title }

//이거도 바디
class _PlanPage_BodyState extends State<PlanPage_Body> {
  late PageController _pageController;
  late int initialPage;

  SortType _sortType = SortType.dDayAsc; // 🔸 정렬 기준 초기값
//일단 여행 정보 예시로
  final List<Map<String, String>> _cardData = [
    {
      'title': '강남구 여행',
      'startDate': '2025.03.10',
      'endDate': '2025.03.28',
    },
    {
      'title': '중구 여행',
      'startDate': '2025.04.01',
      'endDate': '2025.04.10',
    },
    {
      'title': '성북구 여행',
      'startDate': '2025.02.20',
      'endDate': '2025.03.01',
    },
  ];
//정렬용 계산
  int calculateDday(String endDate) {
    final today = DateTime.now();
    final end = DateTime.parse(endDate.replaceAll('.', '-'));
    return end.difference(today).inDays;
  }
//이거 정렬용 기준에 따라 여행 정렬
  List<Map<String, String>> get sortedCardData {
    final sorted = List<Map<String, String>>.from(_cardData);

    switch (_sortType) {
      case SortType.dDayAsc:
        sorted.sort((a, b) => calculateDday(a['endDate']!).compareTo(calculateDday(b['endDate']!)));
        break;
      case SortType.dDayDesc:
        sorted.sort((a, b) => calculateDday(b['endDate']!).compareTo(calculateDday(a['endDate']!)));
        break;
      case SortType.title:
        sorted.sort((a, b) => a['title']!.compareTo(b['title']!));
        break;
    }

    return sorted;
  }

  void _initController() {
    // 🔸 정렬된 리스트 기준으로 가장 가까운 카드 인덱스 계산
    final today = DateTime.now();
    final index = sortedCardData.indexWhere((item) {
      final end = DateTime.parse(item['endDate']!.replaceAll('.', '-'));
      return !end.isBefore(today);
    });
    initialPage = index != -1 ? index : 0;

    // 🔸 PageController 초기화
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialPage,
    );
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  Widget build(BuildContext context) {
    final cards = sortedCardData;

    return Column(
      children: [
        const SizedBox(height: 100),

        // 🔻 정렬 기준 드롭다운
        Container(
          height: 30,width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<SortType>(
            value: _sortType,
            isExpanded: true,
            underline: const SizedBox(), // 밑줄 제거
            icon: const Icon(Icons.keyboard_arrow_down,color: Color(0xFF000000),),
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
              DropdownMenuItem(
                value: SortType.dDayAsc,
                child: Text("날짜순"),
              ),
              DropdownMenuItem(
                value: SortType.dDayDesc,
                child: Text("날짜역순"),
              ),
              DropdownMenuItem(
                value: SortType.title,
                child: Text("제목순"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 📌 카드 슬라이더 여행 카드 부분
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final item = cards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PlanCard(
                  title: item['title']!,
                  startDate: item['startDate']!,
                  endDate: item['endDate']!,
                  size_h: 400,
                  size_w: 250,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 📌 페이지 인디케이터
        PlanPageIndicator(
          controller: _pageController,
          count: cards.length,
        ),
      ],
    );
  }
}

// 📌 커스텀 인디케이터 위젯 그 아래 막 몇번째 있고 그런 거 나타내는 점들 구현
class PlanPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;

  const PlanPageIndicator({
    Key? key,
    required this.controller,
    required this.count,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.black87 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}