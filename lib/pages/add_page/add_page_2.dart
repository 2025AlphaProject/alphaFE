import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import '../../components/save_loading_page.dart';
import '../../components/token_controller.dart';
import 'add_page_3.dart';
import '../../components/app_bar.dart';
import '../../components/proceed_button.dart';
import '../../components/placeinfo_card.dart';
import '../../components/placeinput_card.dart';
import '../../components/ai_loading_page.dart';
import '../../components/date_dropdown.dart';

class AddPage_2 extends StatefulWidget {
  final String title;
  final int tourId;
  final Function(List<PlaceInfoBlock>)? onSaveCourseCallback;
  final bool isSingleDayMode; // New flag to control single day mode

  const AddPage_2({
    required this.title,
    required this.tourId,
    this.onSaveCourseCallback,
    this.isSingleDayMode = false, // default to false for multi-day mode
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
    connectWebSocket();
  }

  // 웹소켓 연결 후 요청된 행정구역에 대한 코스 데이터를 받아 UI에 반영
  void connectWebSocket({int retryCount = 0}) async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    int? userId;
    DateTime? startDate;
    DateTime? endDate;

    // 사용자 ID를 요청하고 최대 3회 재시도
    Future<int?> fetchUserId() async {
      for (int i = 0; i < 3; i++) {
        try {
          final response = await dio.get(
            '$baseUrl/user/me/',
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Accept': 'application/json',
              },
            ),
          );
          return response.data['sub'];
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      return null;
    }

    // 여행 시작일과 종료일을 요청하고 최대 3회 재시도
    Future<Map<String, DateTime>?> fetchTourDates() async {
      for (int i = 0; i < 3; i++) {
        try {
          final response = await dio.get(
            '$baseUrl/tour/${widget.tourId}/',
            options: Options(
              headers: {'Authorization': 'Bearer $accessToken'},
            ),
          );
          return {
            'start': DateTime.parse(response.data['start_date']),
            'end': DateTime.parse(response.data['end_date']),
          };
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      return null;
    }

    userId = await fetchUserId();
    final dates = await fetchTourDates();

    print('userId: $userId, dates: $dates');
    // 사용자 ID 또는 여행 날짜 불러오기에 실패한 경우 사용자에게 알리고 이전 페이지로 이동
    if (userId == null || dates == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("코스 추천 요청 실패: 사용자 정보 또는 여행 날짜 불러오기 오류")),
        );
        Navigator.pop(context);
      }
      return;
    }

    startDate = dates['start'];
    endDate = dates['end'];
    int numberOfDays = endDate!.difference(startDate!).inDays + 1;
    final uniqueCode = Random().nextInt(1 << 31);

    final wsUri = 'ws://conever.duckdns.org:8000/tour/recommend/?user_id=$userId&areaCode=1&sigunguName=${widget.title}&unique_code=$uniqueCode&days=$numberOfDays';

    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUri));
      late StreamSubscription subscription;

      subscription = channel.stream.listen((message) async {
        // 웹소켓 응답이 잘못되었거나 예외 발생 시 재시도 (최대 5회)
        try {
          final data = jsonDecode(message);
          if (_receivedDataOnce || data["result"] == null || data["result"].isEmpty) return;
          if (data["status"] != "SUCCESS") throw Exception("추천 실패");

          _receivedDataOnce = true;
          await subscription.cancel();
          channel.sink.close();

          if (mounted) {
            await processWebSocketData(data);
          }
        } catch (_) {
          await subscription.cancel();
          channel.sink.close();
          if (retryCount < 5) {
            await Future.delayed(const Duration(seconds: 8));
            connectWebSocket(retryCount: retryCount + 1);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("코스 추천 실패: 서버 응답 오류")),
            );
            Navigator.pop(context);
          }
        }
      },
      // 웹소켓 연결 자체에서 오류 발생 시 재시도 (최대 5회)
      onError: (_) async {
        await subscription.cancel();
        channel.sink.close();
        if (retryCount < 5) {
          await Future.delayed(const Duration(seconds: 8));
          connectWebSocket(retryCount: retryCount + 1);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("코스 추천 실패: 서버 연결 오류")),
          );
          Navigator.pop(context);
        }
      });
    } catch (_) {
      // 웹소켓 연결 시도 자체가 실패한 경우 재시도 (최대 5회)
      if (retryCount < 5) {
        await Future.delayed(const Duration(seconds: 8));
        connectWebSocket(retryCount: retryCount + 1);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("코스 추천 연결 실패")),
        );
        Navigator.pop(context);
      }
    }
  }

  // 웹소켓 데이터 응답 처리 함수 (기존 응답 처리 로직 분리)
  Future<void> processWebSocketData(dynamic data) async {
    final context_ = context;
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    if (widget.isSingleDayMode) {
      // 싱글 모드: 첫 번째 날짜 결과만 사용
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

      if (mounted) {
        setState(() {
          _placeWidgets = [MapEntry(widget.title, newWidgets)];
          _isAddingPlaceMap = {for (var e in _placeWidgets) e.key: false};
          _isLoading = false;
        });
      }
    } else {
      // 멀티 모드: 날짜별로 그룹화된 장소 목록 구성
      try {
        // tour_id값을 이용해 여행 시작 날짜와 종료 날짜 불러옴
        final tourResponse = await dio.get(
            '$baseUrl/tour/${widget.tourId}/',
            options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken'
                }
            )
        );
        final startDateStr = tourResponse.data['start_date'];
        final endDateStr = tourResponse.data['end_date'];

        DateTime startDate = DateTime.parse(startDateStr);
        DateTime endDate = DateTime.parse(endDateStr);

        // 시작일과 종료일 기준으로 날짜 리스트 생성
        List<String> dateRange = [];
        for (DateTime date = startDate;
            !date.isAfter(endDate);
            date = date.add(const Duration(days: 1))) {
          dateRange.add(date.toIso8601String().substring(0, 10)); // yyyy-MM-dd 형식
        }

        List<MapEntry<String, List<PlaceInfoBlock>>> groupedWidgets = [];

        for (int i = 0; i < dateRange.length; i++) {
          final date = dateRange[i];
          if (i >= data["result"].length) break;

          final List<dynamic> placesForDate = data["result"][i] as List<dynamic>;
          final filteredCourse = placesForDate.where((place) {
            return place['address']?.toString().contains(widget.title) ?? false;
          }).toList();

          if (filteredCourse.isEmpty) continue;

          final placeInfoBlocks = filteredCourse.take(5).map((place) {
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
          groupedWidgets.add(MapEntry(date, placeInfoBlocks));
        }

        try {
          await Future.wait(groupedWidgets.expand((entry) => entry.value).map((place) async {
            if (place.imageUrl.isNotEmpty) {
              await precacheImage(NetworkImage(place.imageUrl), context_);
            }
          }));
        } catch (e) {
          print("이미지 프리캐싱 실패: $e");
        }

        if (mounted) {
          setState(() {
            _placeWidgets = groupedWidgets;
            _isAddingPlaceMap = {for (var e in _placeWidgets) e.key: false};
            _isLoading = false;
          });
        }
      } catch (e) {
        print('날짜별 장소 데이터 처리 중 오류: $e');
      }
    }
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
    setState(() {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.width;
      final newPlace = PlaceInfoBlock(
        imageUrl: imageUrl,
        title: title,
        description: description,
        mapX: mapX,
        mapY: mapY,
        width: width * 0.58,
        height: width * 0.58 * 0.69,
      );
      final entryIndex = _placeWidgets.indexWhere((entry) => entry.key == date);
      if (entryIndex != -1) {
        _placeWidgets[entryIndex].value.add(newPlace);
      } else {
        _placeWidgets.add(MapEntry(date, [newPlace]));
      }
      _isAddingPlaceMap[date] = false;
    });
  }

  Future<void> saveTourCourse([int? tourId, List<PlaceInfoBlock>? places]) async {
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    final int useTourId = tourId ?? widget.tourId;

    // Show loading dialog before starting to save
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SaveLoadingView(),
    );

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

      // 날짜별로 장소 데이터를 묶어 개별 POST 요청 수행 (모든 날짜를 저장)
      for (var entry in _placeWidgets) {
        final date = entry.key;
        final places = entry.value;

        final List<Map<String, dynamic>> courseData = places.map((place) => {
          'name': place.title,
          'mapX': place.mapX,
          'mapY': place.mapY,
          'image_url': place.imageUrl,
          'road_address': place.description
        }).toList();

        final response = await dio.post(
          '$baseUrl/tour/course/',
          data: {
            'tour_id': '$useTourId',
            'date': date,
            'places': courseData
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken'
            },
          ),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          print('날짜 $date 저장 실패');
        }
      }

      if (!mounted) return;

      // Close the loading view if possible
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the loading view
      }

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => AddPage_3(
            tour_id: widget.tourId,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  // PlaceInfoBlock 목록 상단에 표시되는 안내 문구
  Widget _buildTitleBlock() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("📍${widget.title}", style: TextStyle(fontSize: width * 0.08, fontWeight: FontWeight.w900)),
            SizedBox(width: width * 0.025),
            Text('근처 코스를 알려드릴게요', style: TextStyle(fontSize: width * 0.04, color: const Color(0xFF757575))),
          ],
        ),
        SizedBox(height: height * 0.0138),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('최근 업데이트: ', style: TextStyle(fontSize: width * 0.03, fontWeight: FontWeight.bold, color: const Color(0xFF7F7F7F))),
              SizedBox(width: width * 0.01),
              // 오늘 날짜를 yyyy-MM-dd 형식으로 표시
              Text(DateTime.now().toLocal().toString().substring(0, 10), style: TextStyle(fontSize: width * 0.03, color: const Color(0xFF7F7F7F))),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (_isLoading) {
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
                        dates: _placeWidgets.map((e) => e.key).toList(),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        onChanged: (value) {
                          setState(() {
                            _selectedDate = value;
                          });
                        },
                      ),


                      // 장소 목록 표시 - 그룹화된 날짜별 렌더링
                      if (_placeWidgets.isNotEmpty && _placeWidgets[0].value.isNotEmpty)
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
                      for (var entry in _placeWidgets.where((e) => e.key == _selectedDate)) ...[
                        SizedBox.shrink(),
                        for (var place in entry.value) ...[
                          // 편집 모드일 경우, 각 장소 좌측 상단에 삭제(X) 버튼 표시
                          // 사용자가 해당 버튼을 누르면 해당 장소가 리스트에서 제거됨
                          Stack(
                            children: [
                              place,
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
                                      padding: EdgeInsets.symmetric(vertical: height * .004, horizontal: width * 0.01),
                                      child: Icon(Icons.close, size: width * 0.045, color: Colors.white),
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
                        _isAddingPlaceMap[entry.key] == true
                            ?
                            // 사용자가 장소를 직접 입력하는 카드
                            // onComplete 콜백을 통해 입력한 장소 정보를 해당 날짜 그룹에 추가
                            PlaceInputCard(
                                onComplete: (imageUrl, title, description, mapX, mapY) =>
                                    addNewPlace(entry.key, imageUrl, title, description, mapX, mapY),
                                onCancel: () => setState(() => _isAddingPlaceMap[entry.key] = false),
                              )
                            : GestureDetector(
                                onTap: () => setState(() => _isAddingPlaceMap[entry.key] = true),
                                child: Container(
                                  width: width * 0.63,
                                  height: width * 0.63 * 0.69,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+ 장소 추가',
                                      style: TextStyle(fontSize: width * 0.04),
                                    ),
                                  ),
                                ),
                              ),
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
                        fontSize_: width * 0.037,
                        fontWeight_: FontWeight.bold,
                        onTap: () {

                          // 저장 흐름 분기 처리:
                          // 콜백이 존재하면 AddPage_0으로 이동
                          // 아니면 현재 페이지에서 saveTourCourse 직접 호출
                          if (widget.onSaveCourseCallback != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              widget.onSaveCourseCallback!(_placeWidgets.expand((entry) => entry.value).toList());
                            });
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