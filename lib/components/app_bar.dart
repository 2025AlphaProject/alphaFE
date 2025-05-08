import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import '../pages/add_page/add_page_0.dart';
import '../pages/add_page/add_page_2.dart';
import '../pages/add_page/add_page_3.dart';
import 'placeinfo_card.dart';
import 'dart:math';
import '../main.dart'; // navigatorKey 사용을 위해 import

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const DefaultAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      // AppBar에 그림자 효과 추가
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          )
        ],
      ),
      height: height * 0.147,
      child: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
    );
  }

  // AppBar 높이 설정 (kToolbarHeight = 기본 높이)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatefulWidget {
  final Future<void> Function(int, List<PlaceInfoBlock>) onSaveCourse;

  const SearchAppBar({
    Key? key,
    required this.onSaveCourse,
  }) : super(key: key);


  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final List<String> seoulDistricts = [
    '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구',
    '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구',
    '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구',
    '은평구', '종로구', '중구', '중랑구',
  ];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _removeOverlay();
      if (_searchQuery.isNotEmpty) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  // 오버레이 리스트와 키보드를 화면에서 제거
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!_focusNode.hasPrimaryFocus && _focusNode.hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  // 검색어에 따라 오버레이 리스트를 생성하여 화면에 표시
  OverlayEntry _createOverlayEntry() {
    // 현재 context를 지역 변수에 저장
    final currentContext = context;
    RenderBox renderBox = currentContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // 검색어에 포함되는 행정구역만 필터링
    final filteredDistricts = seoulDistricts.where((gu) => gu.contains(_searchQuery)).toList();

    // 반응형으로 리스트 항목의 높이 및 최대 높이 계산
    final itemHeight = MediaQuery.of(currentContext).size.height * 0.07;
    final maxListHeight = MediaQuery.of(currentContext).size.height * 0.35;
    final listHeight = min(filteredDistricts.length * itemHeight, maxListHeight);

    return OverlayEntry(
      builder: (context) =>
          // 바깥 터치 시 오버레이 제거 및 키보드 숨김
          GestureDetector(
        onTap: () {
          _removeOverlay();
          FocusScope.of(currentContext).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // 오버레이 리스트의 위치를 SearchAppBar 아래로 반응형 배치
            Positioned(
              left: offset.dx + 20,
              top: offset.dy + MediaQuery.of(currentContext).size.height * 0.045,
              width: size.width - 40,
              child: SafeArea( // 시스템 UI 침범 방지
                // 리스트에 그림자와 모서리 둥글기 효과 적용
                child: PhysicalModel(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(MediaQuery.of(currentContext).size.width * 0.03),
                  clipBehavior: Clip.antiAlias,
                  // 리스트 배경, 높이, 내부 패딩 및 항목 구성 설정
                  child: Container(
                    height: listHeight,
                    padding: EdgeInsets.all(MediaQuery.of(currentContext).size.width * 0.02),
                    child: ListView.builder(
                      itemCount: filteredDistricts.length,
                      itemBuilder: (context, index) {
                        final gu = filteredDistricts[index];
                        // 리스트 항목 탭 시 여행 생성 흐름으로 이동
                        return ListTile(
                          title: Text(gu),
                          onTap: () {
                            _searchController.removeListener(_onSearchChanged);
                            _removeOverlay();
                            FocusScope.of(currentContext).unfocus();

                            if (!mounted) return;
                            Navigator.of(currentContext).push(
                              CupertinoPageRoute(
                                builder: (_) => AddPage_2(
                                  title: gu,
                                  tourId: 0,
                                  isSingleDayMode: true,
                                  onSaveCourseCallback: (places) {
                                    Navigator.of(currentContext).push(
                                      CupertinoPageRoute(
                                        builder: (_) => AddPage_0(
                                          onFinishCreation: (int tourId) {
                                            Navigator.of(currentContext).push(
                                              CupertinoPageRoute(
                                                builder: (_) => AddPage_3(
                                                  tour_id: tourId,
                                                ),
                                              ),
                                            );
                                            widget.onSaveCourse(tourId, places);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ).then((_) {
                              if (mounted) {
                                _searchController.addListener(_onSearchChanged);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    // SearchAppBar UI를 화면 상단에 고정 배치
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        // 오버레이 기준 위치 설정 (현재는 제거된 상태)
        child: CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            height: height * 0.055,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.07),
            ),
            // 사용자 입력을 받는 검색창 구현
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '궁금한 여행지를 구 단위로 검색하세요!',
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.7),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.7),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.014,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF1E1E1E)),
                  onPressed: () {
                    // 검색 버튼 눌렀을 때 오버레이 토글 처리
                    if (_overlayEntry == null) {
                      _overlayEntry = _createOverlayEntry();
                      Overlay.of(context).insert(_overlayEntry!);
                    } else {
                      _removeOverlay();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}