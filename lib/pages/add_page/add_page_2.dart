// 필수 패키지 import
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:async'; // Timer 사용을 위해 필요
import 'add_page_3.dart';
import '../../components/app_bar.dart';
import '../../components/proceed_button.dart';
import '../../components/placeinfo_card.dart';

class AddPage_2 extends StatefulWidget {
  final String title;

  const AddPage_2({required this.title, Key? key}) : super(key: key);

  @override
  State<AddPage_2> createState() => _AddPage_2State();
}

class _AddPage_2State extends State<AddPage_2> {
  late ScrollController _scrollController;

  // 버튼 노출 여부 상태 (true = 보임, false = 숨김)
  bool _visibleButton = true;

  // 스크롤이 멈췄을 때 지연 후 버튼을 다시 보이게 하기 위한 타이머
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // 스크롤 추적용 컨트롤러 초기화
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _idleTimer?.cancel(); // 타이머도 안전하게 해제
    super.dispose();
  }

  // 스크롤 상태를 감지하여 버튼을 숨기거나 다시 보여주는 함수
  void myScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;

      // (임시) 유저의 스크롤 방향을 콘솔창에 출력, 개발 완료 시 제거
      print("📢 direction: $direction");

      if (direction == ScrollDirection.idle) {
        // 사용자가 스크롤을 멈췄을 경우 → 타이머가 없을 때만 생성
        _idleTimer ??= Timer(const Duration(milliseconds: 750), () {
          showFloatButton(); // 0.75초 이상 멈춰있으면 버튼 다시 표시
        });
      } else {
        // 스크롤 중일 경우 → 타이머 취소 및 버튼 숨기기
        _idleTimer?.cancel();
        _idleTimer = null;

        if (_visibleButton) {
          hideFloatButton();
        }
      }
    }
  }

  // 버튼 다시 보이기
  void showFloatButton() {
    if (!_visibleButton) {
      setState(() {
        _visibleButton = true;
      });
    }
  }

  // 버튼 숨기기
  void hideFloatButton() {
    if (_visibleButton) {
      setState(() {
        _visibleButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 스크롤 이벤트 감지를 위한 NotificationListener
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              myScrollNotification(notification);
              return false; // 다른 위젯에도 이벤트 전달 허용
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 26),
                      _buildTitleBlock(), // 상단 텍스트
                      const SizedBox(height: 24),
                      // 여행지 카드들
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/...jpg',
                        title: '한강공원',
                        description: '한강의 바람과 함께 산책을 즐길 수 있는 공간입니다.',
                      ),
                      const SizedBox(height: 24),
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/...jpg',
                        title: 'N서울타워',
                        description: '남산 위에서 서울 전경을 감상할 수 있는 타워입니다.',
                      ),
                      const SizedBox(height: 24),
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/...jpg',
                        title: '북촌 한옥마을',
                        description: '조선시대의 전통 한옥이 밀집한 역사적인 마을입니다.',
                      ),

                      const SizedBox(height: 100), // 하단 여유 공간
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 버튼 영역 (애니메이션 적용)
          Visibility(
            visible: _visibleButton, // 버튼 보임 여부
            maintainSize: false,
            maintainAnimation: true,
            maintainState: true,
            child: Stack(
              children: [
                Positioned(
                  bottom: 30, // 화면 하단에서 30만큼 위에 위치
                  left: 0,
                  right: 0, // 좌우 전체 너비 확보

                  // 위젯을 슬라이드 애니메이션과 함께 화면에 표시하거나 숨기기 위한 래퍼
                  child: AnimatedSlide(
                            // 애니메이션이 실행될 총 시간 (0.3초 동안 이동)
                            duration: const Duration(milliseconds: 300),

                            // 이동할 위치를 지정하는 offset (Offset(x, y))
                            // - Offset.zero → 원래 위치 (보임)
                            // - Offset(0, 1.2) → y축으로 아래로 120% 만큼 이동 (사라짐)
                            offset: _visibleButton ? Offset.zero : const Offset(0, 1.2),

                            // 움직임의 가속도 커브 (시작은 느리게 → 빠르게 → 다시 느리게)
                            curve: Curves.easeInOut,

                            child: Center(
                              child: ProceedButton(
                                size_w: 200,
                                size_h: 45,
                                text: "이 코스로 할게요!",
                                fontSize_: 15,
                                fontWeight_: FontWeight.bold,
                                padding_: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(builder: (context) => AddPage_3()),
                                );
                              },
                            ),
                                                        ),
                        )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 상단 텍스트 UI 구성
  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "📍${widget.title}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            const Text(
              '근처 코스를 알려드릴게요',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '최근 업데이트',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7F7F7F)),
            ),
            SizedBox(width: 5),
            Text(
              '2025.00.00',
              style: TextStyle(fontSize: 11, color: Color(0xFF7F7F7F)),
            ),
          ],
        ),
      ],
    );
  }
}