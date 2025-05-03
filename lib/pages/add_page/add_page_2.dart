import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import '../../components/token_controller.dart';
import 'add_page_3.dart';
import '../../components/app_bar.dart';
import '../../components/proceed_button.dart';
import '../../components/placeinfo_card.dart';
import '../../components/placeinput_card.dart';
import '../../components/ai_loading_page.dart';

class AddPage_2 extends StatefulWidget {
  final String title;
  final int tourId;
  final Function(List<PlaceInfoBlock>)? onSaveCourseCallback;

  const AddPage_2({
    required this.title,
    required this.tourId,
    this.onSaveCourseCallback,
    Key? key
  }) : super(key: key);

  @override
  State<AddPage_2> createState() => _AddPage_2State();
}

class _AddPage_2State extends State<AddPage_2> {
  late ScrollController _scrollController;
  bool _visibleButton = true;
  Timer? _idleTimer;
  bool _isLoading = true;
  bool _receivedDataOnce = false; // 최초 데이터 수신 여부를 기록하는 플래그

  // 장소 데이터 목록 (API에서 받아온 데이터와 사용자가 추가한 입력 모두 포함)
  List<PlaceInfoBlock> _placeWidgets = [];

  // 현재 장소 추가 입력폼이 열려있는지 여부
  bool _isAddingPlace = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    connectWebSocket();
  }

  // 웹소켓 연결 후 요청된 행정구역에 대한 코스 데이터를 받아 UI에 반영
  void connectWebSocket() async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    // 사용자 ID 불러오기
    final userResponse = await dio.get(
      '$baseUrl/user/me/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ),
    );

    final userId = userResponse.data['sub'];
    final uniqueCode = Random().nextInt(1 << 31); // 랜덤 정수 생성

    final channel = WebSocketChannel.connect(
      Uri.parse('ws://conever.duckdns.org:8000/tour/recommend/?user_id=$userId&areaCode=1&sigunguName=${widget.title}&unique_code=$uniqueCode'),
    );

    late StreamSubscription subscription;

    subscription = channel.stream.listen((message) async {
      final data = jsonDecode(message);

      if (_receivedDataOnce || data["result"] == null || data["result"].isEmpty) return;

      if (data["status"] == "SUCCESS" && data["result"] != null) {
        final context_ = context;

        final List<dynamic> filteredCourse = (data["result"][0] as List).where((place) {
          return place['address']?.toString().contains(widget.title) ?? false;
        }).toList();

        if (filteredCourse.isEmpty) return;

        final newWidgets = filteredCourse.take(5).map((place) {
          final imageUrl = (place['image1'] != null && place['image1'].toString().isNotEmpty)
              ? place['image1']
              : '';

          return PlaceInfoBlock(
            imageUrl: imageUrl,
            title: place['title'] ?? '제목 없음',
            description: place['address'] ?? '주소 정보 없음',
            mapX: double.tryParse(place['mapX'] ?? '0') ?? 0.0,
            mapY: double.tryParse(place['mapY'] ?? '0') ?? 0.0,
            width: MediaQuery.of(context_).size.width * 0.63,
            height: MediaQuery.of(context_).size.width * 0.63 * 0.69,
          );
        }).toList();

        try {
          await Future.wait(newWidgets.map((place) async {
            if (place.imageUrl.isNotEmpty) {
              await precacheImage(NetworkImage(place.imageUrl), context_);
            }
          }));
        } catch (e) {
          print("이미지 프리캐싱 실패: $e");
        }

        _receivedDataOnce = true;
        await subscription.cancel();
        channel.sink.close();

        if (mounted) {
          setState(() {
            _placeWidgets = newWidgets;
            _isLoading = false;
          });
        }
      }
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

  // 사용자가 새 장소를 추가 완료하면 PlaceInfoBlock 리스트에 추가하고 입력폼 닫기
  void addNewPlace(String imageUrl, String title, String description, double mapX, double mapY) {
    setState(() {
      _placeWidgets.add(
        PlaceInfoBlock(
          imageUrl: imageUrl,
          title: title,
          description: description,
          mapX: mapX,
          mapY: mapY,
          width: MediaQuery.of(context).size.width * 0.58,
          height: MediaQuery.of(context).size.width * 0.58 * 0.69,
        ),
      );
      _isAddingPlace = false;
    });
  }

  Future<void> saveTourCourse([int? tourId, List<PlaceInfoBlock>? places]) async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    final int useTourId = tourId ?? widget.tourId;
    final List<PlaceInfoBlock> usePlaces = places ?? _placeWidgets;

    try {
      // tour_id값을 이용해 여행 시작 날짜 불러옴
      final startDateResponse = await dio.get(
          '$baseUrl/tour/$useTourId/',
          options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken'
              }
          )

      );
      final startDate = startDateResponse.data['start_date'];

      // 서버에 전송할 장소 이름과 주소에서 불필요한 <> 기호 제거
      final List<Map<String, dynamic>> courseData = usePlaces.map((place) => {
        'name': place.title,
        'mapX': place.mapX,
        'mapY': place.mapY,
        'image_url': place.imageUrl,
        'road_address': place.description
      }).toList();

      // 내 여행 경로 저장
      final response = await dio.post(
        '$baseUrl/tour/course/',
        data: {
          'tour_id': '$useTourId',
          'date': startDate,
          'places': courseData
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 성공 시 다음 페이지로 이동
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AddPage_3(
              tour_id: widget.tourId,
            ),
          ),
        );
      } else {
        print('등록 실패');
      }
    } catch (e) {
      print(e);
    }
  }

  // PlaceInfoBlock 목록 상단에 표시되는 안내 문구
  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("📍${widget.title}", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, fontWeight: FontWeight.bold)),
            SizedBox(width: MediaQuery.of(context).size.width * 0.038),
            Text('근처 코스를 알려드릴게요', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035, color: const Color(0xFF757575))),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.03),
        Row(
          children: [
            Text('최근 업데이트', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.027, fontWeight: FontWeight.bold, color: const Color(0xFF7F7F7F))),
            SizedBox(height: MediaQuery.of(context).size.width * 0.018),

            // TODO: 최근 업데이트 날짜 구현 필요
            Text('2025.00.00', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.027, color: const Color(0xFF7F7F7F))),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AILoadingView();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "추가페이지_2nd"),
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
                  vertical: MediaQuery.of(context).size.width * 0.03,
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),

                  // 장소 정보 블록들을 나열하는 최상위 Column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width * 0.063),
                      _buildTitleBlock(),
                      SizedBox(height: MediaQuery.of(context).size.width * 0.058),

                      // 장소 목록 표시
                      ..._placeWidgets.map((place) => Column(
                        children: [
                          place,
                          SizedBox(height: MediaQuery.of(context).size.width * 0.058),
                        ],
                      )),

                      // 장소 추가 입력폼 또는 '+ 장소 추가' 버튼 표시
                      _isAddingPlace

                      // '+ 장소 추가' 버튼 클릭 시 입력폼으로 전환
                          ? PlaceInputCard(
                        onComplete: addNewPlace,
                        onCancel: () => setState(() => _isAddingPlace = false),
                      )

                      // 기본 상태, '+ 장소 추가' 버튼 표시
                          : GestureDetector(
                        onTap: () => setState(() => _isAddingPlace = true),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.63,
                          height: MediaQuery.of(context).size.width * 0.63 * 0.69,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '+ 장소 추가',
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.width * 0.2835),
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
                  bottom: MediaQuery.of(context).size.width * 0.075,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: _visibleButton ? Offset.zero : const Offset(0, 1.2),
                    curve: Curves.easeInOut,
                    child: Center(
                      child: ProceedButton(
                        size_w: MediaQuery.of(context).size.width * 0.53,
                        size_h: MediaQuery.of(context).size.width * 0.12,
                        text: "이 코스로 할게요!",
                        fontSize_: MediaQuery.of(context).size.width * 0.037,
                        fontWeight_: FontWeight.bold,
                        onTap: () {

                          // 저장 흐름 분기 처리:
                          // 콜백이 존재하면 AddPage_0으로 이동
                          // 아니면 현재 페이지에서 saveTourCourse 직접 호출
                          if (widget.onSaveCourseCallback != null) {
                            widget.onSaveCourseCallback!(_placeWidgets);
                          } else {
                            saveTourCourse();
                          }
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
