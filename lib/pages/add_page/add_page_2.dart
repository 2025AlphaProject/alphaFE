import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
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
  bool _visibleButton = true;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _idleTimer?.cancel();
    super.dispose();
  }

  void myScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      print("📢 direction: $direction");

      if (direction == ScrollDirection.idle) {
        // idle 상태가 유지될 경우 → 타이머 시작 (없을 때만)
        _idleTimer ??= Timer(const Duration(milliseconds: 2000), () {
          showFloatButton();
        });
      } else {
        // 스크롤 중이면 → 타이머 초기화 & 버튼 숨김
        _idleTimer?.cancel();
        _idleTimer = null;

        if (_visibleButton) {
          hideFloatButton();
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),
      body: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              myScrollNotification(notification);
              return false;
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
                      _buildTitleBlock(),
                      const SizedBox(height: 24),
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/여의도_한강공원.jpg/1280px-여의도_한강공원.jpg',
                        title: '한강공원',
                        description: '한강의 바람과 함께 산책을 즐길 수 있는 공간입니다.',
                      ),
                      const SizedBox(height: 24),
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/ba/Seoul_Tower_%284394893276%29.jpg',
                        title: 'N서울타워',
                        description: '남산 위에서 서울 전경을 감상할 수 있는 타워입니다.',
                      ),
                      const SizedBox(height: 24),
                      PlaceInfoBlock(
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Bukchon_Hanok_Village_북촌_한옥마을_October_1_2020_15.jpg/1920px-Bukchon_한옥마을.jpg',
                        title: '북촌 한옥마을',
                        description: '조선시대의 전통 한옥이 밀집한 역사적인 마을입니다.',
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 버튼 영역 (애니메이션 없음)
          Visibility(
            visible: _visibleButton,
            maintainSize: false,
            maintainAnimation: true,
            maintainState: true,
            child: Stack(
              children: [

                // ✅ 애니메이션 적용된 Positioned
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0, // 가운데 정렬할 수 있도록 추가
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: _visibleButton ? Offset.zero : const Offset(0, 1.2),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _visibleButton ? 1.0 : 0.0,
                      child: Center( // 버튼 가운데 정렬
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
                    ),
                  ),
                ),
              ],
            )
          )
        ],
      ),
    );
  }

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
