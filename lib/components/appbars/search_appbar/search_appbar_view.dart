import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../pages/add_page/add_page_0/add_page_0.dart';
import 'search_appbar_viewmodel.dart';
import 'dart:math';


class SearchAppBar extends StatefulWidget {
  final String? accessToken;

  const SearchAppBar({
    Key? key,
    required this.accessToken,
  }) : super(key: key);


  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SearchAppBarViewModel>(context, listen: false);
    viewModel.init();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    final viewModel = Provider.of<SearchAppBarViewModel>(context, listen: false);
    viewModel.disposeVM();
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
    final viewModel = Provider.of<SearchAppBarViewModel>(context, listen: false);
    // 현재 context를 지역 변수에 저장
    final currentContext = context;
    RenderBox renderBox = currentContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 390.0;
    }

    final filteredDistricts = viewModel.filteredDistricts;

    // 반응형으로 리스트 항목의 높이 및 최대 높이 계산
    final itemHeight = 50.0;
    final maxListHeight = 250.0;
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
              left: 20.0,
              top: offset.dy + 60.0,
              width: width,
              child: SafeArea( // 시스템 UI 침범 방지
                // 리스트에 그림자와 모서리 둥글기 효과 적용
                child: PhysicalModel(
                  color: Color(0xFFFFFFFF),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  // 리스트 배경, 높이, 내부 패딩 및 항목 구성 설정
                  child: Container(
                    height: listHeight,
                    padding: EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: filteredDistricts.length,
                      itemBuilder: (context, index) {
                        final gu = filteredDistricts[index];
                        // 리스트 항목 탭 시 AddPage_0으로만 이동하도록 수정
                        return ListTile(
                          title: Text(gu),
                          onTap: () {
                            final viewModel = Provider.of<SearchAppBarViewModel>(context, listen: false);
                            viewModel.searchController.removeListener(viewModel.onSearchChanged);
                            _removeOverlay();
                            FocusScope.of(currentContext).unfocus();

                            if (!mounted) return;
                            Navigator.of(currentContext).push(
                              CupertinoPageRoute(
                                builder: (_) => AddPage_0(
                                  sigun: gu,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) {
                                viewModel.searchController.addListener(viewModel.onSearchChanged);
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
    final viewModel = Provider.of<SearchAppBarViewModel>(context);
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
              controller: viewModel.searchController,
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