import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_view_model.dart';
import 'package:alpha_fe/services/http/save_tour_course/save_tour_course_from_add.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../components/app_bar.dart';
import '../../../components/proceed_button.dart';
import '../../../components/placeinfo_card.dart';
import '../../../components/placeinput_card.dart';
import '../../../components/ai_loading_page.dart';
import '../../../components/date_dropdown.dart';
import '../../../components/custom_alert_dialog.dart';

class AddPage_2 extends StatefulWidget {
  final String? accessToken;
  final String title;
  final int tourId;

  const AddPage_2({
    required this.title,
    required this.tourId,
    Key? key, required this.accessToken
  }) : super(key: key);

  @override
  State<AddPage_2> createState() => _AddPage_2State();
}

class _AddPage_2State extends State<AddPage_2> {
  late ScrollController _scrollController;
  bool _visibleButton = true;
  Timer? _idleTimer;

  // 편집 모드 토글 상태를 저장 (true: 삭제 버튼 표시)
  bool _isEditMode = false; // 편집 모드 여부

  // 날짜별로 그룹화된 장소 데이터 목록 (날짜: 장소 리스트 쌍)
  List<MapEntry<String, List<PlaceInfoBlock>>> _placeWidgets = [];

  // 날짜별로 장소 추가 입력폼이 열려있는지 여부를 관리하는 맵
  Map<String, bool> _isAddingPlaceMap = {};

  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.microtask(() {
      final viewModel = Provider.of<ShowTourCourseViewModel>(context, listen: false);
      viewModel.fetchCourseRecommendation(
        context: context,
        tourId: widget.tourId,
        areaName: widget.title,
        isWeb: kIsWeb,
      );
    });
  }

  // 스크롤 상태에 따라 '이 코스로 할게요!' 버튼의 애니메이션을 제어
  void myScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.idle) {
        _idleTimer ??= Timer(const Duration(milliseconds: 750), () {
          showFloatButton();
        });
      } else {
        _idleTimer?.cancel();
        _idleTimer = null;
        if (_visibleButton) hideFloatButton();
      }
    }
  }

  void showFloatButton() {
    if (!_visibleButton) {
      setState(() {
        _visibleButton = true;
      });
    }
  }

  void hideFloatButton() {
    if (_visibleButton) {
      setState(() {
        _visibleButton = false;
      });
    }
  }

  // 사용자가 새 장소를 추가 완료하면 해당 날짜 그룹에 PlaceInfoBlock을 추가하고 입력폼 닫기
  void addNewPlace(String date, String imageUrl, String title, String description, double mapX, double mapY) {

    final entryIndex = _placeWidgets.indexWhere((entry) => entry.key == date);
    final existingList = entryIndex != -1 ? _placeWidgets[entryIndex].value : [];

    // 동일한 날짜 그룹 내에 이미 같은 정보의 장소가 있는지 확인 (좌표 근접 + 텍스트 유사)
    final isDuplicate = existingList.any((place) {
      // 정확한 장소명 비교
      if (place.title == title) {
        return true;
      }

      // 괄호 제거 함수
      String stripParentheses(String input) {
        return input.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
      }

      // 기존 및 새 주소에서 괄호 포함된 부분 제거
      final strippedExistingAddress = stripParentheses(place.description);
      final strippedNewAddress = stripParentheses(description);

      // 주소가 같을 경우 공백 제거 후 비교
      if (strippedExistingAddress == strippedNewAddress) {
        final normalize = (String s) => s.replaceAll(RegExp(r'\s+'), '');
        if (normalize(strippedExistingAddress) == normalize(strippedNewAddress)) {
          return true;
        }
      }

      return false;
    });
    if (isDuplicate) {
      // 중복될 경우 안내 다이얼로그 표시 후 추가 중단
      showDialog(
        context: context,
        builder: (context) => const CustomAlertDialog(
          title: '안내',
          contentText: '이미 추가된 장소입니다',
        ),
      );
      return;
    }

    setState(() {
      double width = MediaQuery.of(context).size.width;
      if (kIsWeb) {
        width = 430;
      }
      final height = MediaQuery.of(context).size.height;
      final newPlace = PlaceInfoBlock(
        imageUrl: imageUrl,
        title: title,
        description: description,
        mapX: mapX,
        mapY: mapY,
        width: width * 0.63,
        height: height * 0.2//width* 0.63* 0.69,
      );
      if (entryIndex != -1) {
        _placeWidgets[entryIndex].value.add(newPlace);
      } else {
        _placeWidgets.add(MapEntry(date, [newPlace]));
      }
      _isAddingPlaceMap[date] = false;
    });
  }


  // PlaceInfoBlock 목록 상단에 표시되는 안내 문구
  Widget _buildTitleBlock() {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (kIsWeb) {
      width = 430;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📍${widget.title}", style: const TextStyle(fontSize: 26.7, fontWeight: FontWeight.w900)),
        const Padding(
          padding: EdgeInsets.only(left: 37.5),
          child: Text('근처 코스를 알려드릴게요', style: TextStyle(fontSize: 14.3, color: Color(0xFF757575))),
        ),
        SizedBox(height: height * 0.0138),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('최근 업데이트: ', style: TextStyle(fontSize: 14.3, fontWeight: FontWeight.bold, color: Color(0xFF7F7F7F))),
              SizedBox(width: width * 0.01),
              // 오늘 날짜를 yyyy-MM-dd 형식으로 표시
              Text(DateTime.now().toLocal().toString().substring(0, 10), style: TextStyle(fontSize: width * 0.03, color: const Color(0xFF7F7F7F))),
            ],
          ),
        ),
      ],
    );
  }

  // 날짜별 섹션 제목을 그리는 위젯
  Widget _buildDateDropdown() {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: DropdownButton<String>(
        value: _selectedDate,
        isExpanded: true,
        dropdownColor: const Color(0xFFF5F5F5),
        hint: const Text("날짜를 선택해주세요", style: TextStyle(fontSize: 18.5, color: Colors.black)),
        items: _placeWidgets.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.key, style: const TextStyle(fontSize: 20.5, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDate = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final viewModel = context.watch<ShowTourCourseViewModel>();
    final placeWidgets = viewModel.placeMap.entries.toList();
    if (kIsWeb) {
      width = 430;
    }
    if (viewModel.isLoading) {
      return const AILoadingView();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "새 여행지 추가"),
      body: Stack(
        alignment: Alignment.center,
        children: [

          // 스크롤 리스너를 통해 버튼의 애니메이션 상태를 제어
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              myScrollNotification(notification);
              return false;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.0138,
                  horizontal: width * 0.06,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height,
                    minWidth: width,
                  ),

                  // 장소 정보 블록들을 나열하는 최상위 Column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.028),
                      _buildTitleBlock(),
                      SizedBox(height: height * 0.0267),
                      DateDropdown(
                        selectedDate: ValueNotifier<String?>(_selectedDate),
                        dates: placeWidgets.map((e) => e.key).toList(),
                        height: height,
                        width: width,
                        onChanged: (value) {
                          setState(() {
                            _selectedDate = value;
                          });
                        },
                      ),


                      // 장소 목록 표시 - 그룹화된 날짜별 렌더링
                      if (placeWidgets.isNotEmpty && placeWidgets[0].value.isNotEmpty)
                        // 편집모드 토글 버튼
                        // 연필 아이콘: 편집 모드로 진입하여 각 장소에 삭제(X) 버튼 노출
                        // 저장 아이콘: 편집 모드 종료 및 삭제 버튼 숨김
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(
                              _isEditMode ? Icons.save : Icons.edit,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditMode = !_isEditMode;
                              });
                            },
                          ),
                        ),
                      for (var entry in placeWidgets.where((e) => e.key == _selectedDate)) ...[
                        SizedBox.shrink(),
                        for (var place in entry.value) ...[
                          Stack(
                            children: [
                              PlaceInfoBlock(
                                imageUrl: place.imageUrl,
                                title: place.title,
                                description: place.description,
                                mapX: place.mapX,
                                mapY: place.mapY,
                                width: width * 0.63,
                                height: height * 0.2,
                              ),
                              if (_isEditMode)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        entry.value.remove(place);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: height * .004,
                                        horizontal: width * 0.01,
                                      ),
                                      child: const Icon(Icons.close, size: 18.5, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: height * 0.0268),
                        ],
                        // 날짜별로 추가된 코스 아래에 위치하는 '+ 장소 추가' 버튼
                        // 버튼을 누르면 해당 날짜에 새로운 장소 입력폼(PlaceInputCard) 표시됨
                        // 사용자가 입력을 완료하면 해당 날짜 섹션에만 장소가 추가됨
                        (_isAddingPlaceMap[entry.key] == true && !kIsWeb)
                            ? PlaceInputCard(
                                onComplete: (imageUrl, title, description, mapX, mapY) =>
                                    addNewPlace(entry.key, imageUrl, title, description, mapX, mapY),
                                onCancel: () => setState(() => _isAddingPlaceMap[entry.key] = false),
                              )
                            : (!kIsWeb
                                ? GestureDetector(
                                    onTap: () => setState(() => _isAddingPlaceMap[entry.key] = true),
                                    child: Container(
                                      width: width * 0.63,
                                      height: height * 0.2,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '+ 장소 추가',
                                          style: TextStyle(fontSize: 16.5),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink()),
                        SizedBox(height: height * 0.0184),
                      ],
                      SizedBox(height: height * 0.13),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // '이 코스로 할게요!' 버튼, 고정 위치에 애니메이션 효과 적용
          Visibility(
            visible: _visibleButton,
            maintainSize: false,
            maintainAnimation: true,
            maintainState: true,
            child: Stack(
              children: [
                Positioned(
                  bottom: height * 0.0344,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: _visibleButton ? Offset.zero : const Offset(0, 1.2),
                    curve: Curves.easeInOut,
                    child: Center(
                      child: ProceedButton(
                        size_w: width * 0.53,
                        size_h: height * 0.055,
                        text: "이 코스로 할게요!",
                        fontSize_: 14.3,
                        fontWeight_: FontWeight.bold,
                        onTap: () async {
                            await SaveTourCourseFromAdd().saveCourse(
                              context: context,
                              placeWidgets: _placeWidgets,
                              tourId: widget.tourId,
                            );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}