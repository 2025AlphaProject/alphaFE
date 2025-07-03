import 'package:alpha_fe/components/plan_card.dart';
import 'package:alpha_fe/pages/plan_page/plan_page_1/viewModel/plan_sort_viewModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../components/app_bar.dart';
import 'package:provider/provider.dart';

// 전역 상태 관리 클래스
class EditState {
  static bool showEditButton = false;
}

class PlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SortViewModel>(
      create: (_) => SortViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: const DefaultAppBar(title: "나의 계획"),
        body: PlanPage_Body(),
      ),
    );
  }
}

class PlanPage_Body extends StatefulWidget {

  @override
  State<PlanPage_Body> createState() => _PlanPage_BodyState();
}

class _PlanPage_BodyState extends State<PlanPage_Body> {
  late PageController _pageController;
  late int initialPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SortViewModel>(context, listen: false);
      viewModel.fetchTours(context);
    });
  }

  //기준별 정렬 관련들
  void _initController(List<Map<String, dynamic>> sortedCardData) {
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<SortViewModel>(context);
    final cards = viewModel.sortedCardData;
    final isLoading = viewModel.isLoading;
    final sortType = viewModel.sortType;

    if (kIsWeb) {
      width = 430;
    }

    if (!isLoading && cards.isNotEmpty && (_pageController == null || !_pageController.hasClients)) {
      _initController(cards);
    }

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : cards.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('등록된 여행이 없습니다.',
                        style: TextStyle(
                            fontSize: 18.5)),
                    Text('여행을 추가해주세요!',
                        style: TextStyle(
                            fontSize: 24.6,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<SortType>(
            value: sortType,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF000000),
                size: 20.5),
            dropdownColor: Colors.white,
            onChanged: (value) {
              if (value != null) {
                viewModel.setSortType(value);
                _initController(viewModel.sortedCardData);
              }
            },
            items: const [
              DropdownMenuItem(value: SortType.dDayAsc,
                  child: Text(
                      "날짜순", style: TextStyle(fontSize: 14.3))),
              DropdownMenuItem(value: SortType.dDayDesc,
                  child: Text(
                      "날짜역순", style: TextStyle(fontSize: 14.3))),
              DropdownMenuItem(value: SortType.title,
                  child: Text(
                      "제목순", style: TextStyle(fontSize: 14.3))),
            ],
          ),
        ),

        SizedBox(height: height * 0.03),

        // 카드 슬라이더
        SizedBox(
          height: height * 0.4,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
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
    double width = MediaQuery.of(context).size.width;
    final dotSize = widget.dotSize ?? width * 0.02;
    final dotActiveWidth = widget.dotActiveWidth ?? width * 0.03;
    if (kIsWeb) {
      width = 430;
    }

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