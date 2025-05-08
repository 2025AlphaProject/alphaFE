import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:alpha_fe/components/auth_token_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../components/app_bar.dart';
import '../../components/logout_by_expiration.dart';
import '../../components/plan_card.dart'; // 여행 계획 카드 컴포넌트
import '../../components/placeinfo_card.dart';
import '../../components/proceed_button.dart'; // 버튼 컴포넌트
import '../add_page/add_page_0.dart';
import '../add_page/add_page_2.dart';
import '../add_page/add_page_3.dart';
import '../../components/token_controller.dart'; // 버튼 컴포넌트
import '../../components/custom_alert_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  Map<String, dynamic>? _nearestPlan;
  String? _currentUsername;
  Map<String, dynamic>? _recommendedPlace;

  @override
  void initState() {
    super.initState();
    fetchPlans();
    _fetchRecommendedPlace();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> fetchPlans() async {
    final accessToken = await getAccessToken();
    print('accessToken:$accessToken');
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    try {
      // /user/me/ API 호출하여 현재 사용자 정보 가져오기
      final userResponse = await dio.get(
        '$baseUrl/user/me/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json'
          },

        ),
      );

      // 현재 사용자 이름 추출
      final currentUsername = userResponse.data['username'];
      if (!mounted) return;
      setState(() {
        _currentUsername = currentUsername;
      });

      // /tour/ API 호출하여 전체 여행 목록 가져오기
      final tourResponse = await dio.get(
        '$baseUrl/tour/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json'
          },
        ),
      );

      // 전체 여행 목록에서 현재 사용자 이름과 일치하는 여행만 필터링
      final List<dynamic> allPlans = tourResponse.data;
      final List<dynamic> userPlans = allPlans.where((plan) {
        final List<dynamic> users = plan['user'] ?? [];
        return users.any((u) => u['username'] == currentUsername);
      }).toList();

      // 여행 목록 필터링 후 불완전한 여행(코스 없음) 및 종료된 여행(만료일 지난 경우)을 제거하는 과정
      final List<dynamic> validUserPlans = [];

      for (final plan in userPlans) {
        final int tourId = int.tryParse(plan['id'].toString()) ?? -1;
        final endDateStr = plan['end_date'];
        final endDate = DateTime.tryParse(endDateStr.replaceAll('.', '-'));
        final today = DateTime.now();
        final isExpired = endDate != null && today.isAfter(DateTime(endDate.year, endDate.month, endDate.day).add(Duration(days: 1)));
        try {
          final courseResponse = await dio.get(
            '$baseUrl/tour/course/$tourId/',
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Accept': 'application/json'
              },
            ),
          );

          if ((courseResponse.data is Map &&
              courseResponse.data['courses'] is List &&
              (courseResponse.data['courses'] as List).isEmpty) || isExpired) {
            await dio.delete(
              '$baseUrl/tour/$tourId/',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
              ),
            );
            continue; // 삭제된 항목은 추가하지 않음
          }

          validUserPlans.add(plan); // 유효한 여행만 추가
        } catch (e) {
          print('삭제 실패: $e');
          continue;
        }
      }

      // 여행 계획이 존재하는지 확인
      if (validUserPlans.isNotEmpty) {
        DateTime now = DateTime.now();
        validUserPlans.sort((a, b) {
          DateTime aStart = DateTime.parse(a['start_date']);
          DateTime bStart = DateTime.parse(b['start_date']);
          Duration aDiff = aStart.difference(now).abs();
          Duration bDiff = bStart.difference(now).abs();
          return aDiff.compareTo(bDiff);
        });
        final nearest = validUserPlans.first;
        setState(() {
          _nearestPlan = {
            'id': nearest['id'],
            'title': nearest['tour_name'] ?? '제목 없음',
            'start_date': nearest['start_date'] ?? '',
            'end_date': nearest['end_date'] ?? '',
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _nearestPlan = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 엑세스 토큰 만료 시 리프레시 토큰을 사용해 재발급
      if (e is DioException && e.response?.statusCode == 403) {
        final bool? result = await getAccessTokenFromRefreshToken();
        if (result == false) {
          LogoutByExpiration(context);
        }
        await fetchPlans();
        return;
      }
      setState(() {
        _nearestPlan = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRecommendedPlace({int retryCount = 0}) async {
    print('트렌딩 장소 가져오기 시작...');
    print('[DEBUG] 사용자 ID 요청 시작');
    final accessToken = await getAccessToken();
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';

    // 사용자 ID를 최대 3회까지 재시도해서 받아오는 함수
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
          print('[DEBUG] 사용자 ID 요청 성공: ${response.data['sub']}');
          return response.data['sub'];
        } catch (_) {
          print('[DEBUG] 사용자 ID 요청 실패 - 재시도 중 (${i + 1}/3)');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      return null;
    }

    final userId = await fetchUserId();
    if (userId == null) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const CustomAlertDialog(
            title: '트렌딩 페이지 오류',
            contentText: '사용자 정보를 불러오는 데 실패했습니다.',
          ),
        );
      }
      return;
    }

    // 서울시 행정구역 목록
    const List<String> districts = [
      "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구",
      "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구",
      "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
    ];
    final String randomDistrict = districts[Random().nextInt(districts.length)];
    print('[DEBUG] 랜덤 행정구역 선택: $randomDistrict');

    final uniqueCode = Random().nextInt(1 << 31);

    try {
      final channel = WebSocketChannel.connect(
        Uri.parse('ws://conever.duckdns.org:8000/tour/recommend/?user_id=$userId&areaCode=1&unique_code=$uniqueCode&days=1&sigunguName=$randomDistrict'),
      );
      print('[DEBUG] 웹소켓 채널 연결 완료: $uniqueCode');

      late StreamSubscription subscription;

      subscription = channel.stream.listen((message) async {
        try {
          final data = jsonDecode(message);
          print('[DEBUG] 웹소켓 메시지 수신: $message');

          // "state": "OK"인 중간 응답은 무시
          if (data['state'] == 'OK') {
            print('[DEBUG] 중간 응답(OK) 수신 - 무시');
            return;
          }

          // 새 조건 분기
          if (_recommendedPlace != null) {
            print('[DEBUG] 이미 추천 장소 있음 - 무시');
            return;
          }

          // status == SUCCESS 형태의 응답 처리
          if (data['status'] == 'SUCCESS' && data['result'] != null) {
            dynamic result = data['result'];
            if (result is String) {
              result = jsonDecode(result);
            }

            final List<dynamic> flatPlaces = result.expand((course) => course is List ? course : []).toList();
            final filteredPlaces = flatPlaces.where((place) => (place['image1'] ?? '').isNotEmpty).toList();

            if (filteredPlaces.isEmpty) {
              print('[DEBUG] 유효한 장소 없음');
              throw '유효한 장소 없음';
            }

            final selectedPlace = filteredPlaces[Random().nextInt(filteredPlaces.length)];

            // 이미지 URL 처리 방식 변경
            final originalUrl = selectedPlace['image1']?.toString() ?? '';
            final secureUrl = originalUrl.replaceFirst('http://', '');
            final imageUrl = (secureUrl.isNotEmpty)
                ? (kIsWeb ? 'https://images.weserv.nl/?url=$secureUrl' : 'http://$secureUrl')
                : '';
            selectedPlace['image1'] = imageUrl;

            try {
              if (!kIsWeb) {
                await precacheImage(NetworkImage(selectedPlace['image1']), context);
              }
            } catch (e) {
              print("이미지 프리캐싱 실패 (앱에서만): $e");
            }

            if (!mounted) return;

            print('[DEBUG] 추천 장소 선택 완료: ${selectedPlace['title']}');
            setState(() {
              _recommendedPlace = selectedPlace;
            });

            try {
              await subscription.cancel();
            } catch (_) {}
            try {
              channel.sink.close();
            } catch (_) {}
            return;
          }

          // 기존 Message/result 방식(예전 서버 구조)도 fallback 가능하게 남겨둠
          final dynamic messageContent = data['Message'];
          if (messageContent == null || messageContent['result'] == null) {
            print('[DEBUG] 응답 오류 또는 result 없음 - 재시도 조건 확인');
            throw '추천 실패';
          }

          dynamic result = messageContent['result'];
          if (result is String) {
            result = jsonDecode(result);
          }

          final List<dynamic> flatPlaces = result.expand((course) => course is List ? course : []).toList();
          final filteredPlaces = flatPlaces.where((place) => (place['image1'] ?? '').isNotEmpty).toList();

          if (filteredPlaces.isEmpty) {
            print('[DEBUG] 유효한 장소 없음');
            throw '유효한 장소 없음';
          }

          final selectedPlace = filteredPlaces[Random().nextInt(filteredPlaces.length)];

          // 이미지 URL 처리 방식 변경
          final originalUrl = selectedPlace['image1']?.toString() ?? '';
          final secureUrl = originalUrl.replaceFirst('http://', '');
          final imageUrl = (secureUrl.isNotEmpty)
              ? (kIsWeb ? 'https://images.weserv.nl/?url=$secureUrl' : 'http://$secureUrl')
              : '';
          selectedPlace['image1'] = imageUrl;

          try {
            if (!kIsWeb) {
              await precacheImage(NetworkImage(selectedPlace['image1']), context);
            }
          } catch (e) {
            print("이미지 프리캐싱 실패 (앱에서만): $e");
          }

          if (!mounted) return;

          print('[DEBUG] 추천 장소 선택 완료: ${selectedPlace['title']}');
          setState(() {
            _recommendedPlace = selectedPlace;
          });

          try {
            await subscription.cancel();
          } catch (_) {}
          try {
            channel.sink.close();
          } catch (_) {}
        } catch (e) {
          print('[DEBUG] 웹소켓 오류 발생 또는 종료 - 재시도 여부 확인 중');
          try {
            await subscription.cancel();
          } catch (_) {}
          try {
            channel.sink.close();
          } catch (_) {}

          if (retryCount < 5) {
            await Future.delayed(const Duration(seconds: 8));
            _fetchRecommendedPlace(retryCount: retryCount + 1);
          } else if (mounted) {
            await showDialog(
              context: context,
              builder: (_) => const CustomAlertDialog(
                title: '트렌딩 페이지 오류',
                contentText: '추천 장소를 가져오는 데 실패했습니다.',
              ),
            );
          }
        }
      }, onError: (_) async {
        print('[DEBUG] 웹소켓 오류 발생 또는 종료 - 재시도 여부 확인 중');
        try {
          await subscription.cancel();
        } catch (_) {}
        try {
          channel.sink.close();
        } catch (_) {}

        if (retryCount < 5) {
          await Future.delayed(const Duration(seconds: 8));
          _fetchRecommendedPlace(retryCount: retryCount + 1);
        } else if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => const CustomAlertDialog(
              title: '트렌딩 페이지 오류',
              contentText: '추천 장소를 가져오는 데 실패했습니다.',
            ),
          );
        }
      });
    } catch (_) {
      print('[DEBUG] 웹소켓 오류 발생 또는 종료 - 재시도 여부 확인 중');
      if (retryCount < 5) {
        await Future.delayed(const Duration(seconds: 8));
        _fetchRecommendedPlace(retryCount: retryCount + 1);
      } else if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const CustomAlertDialog(
            title: '트렌딩 페이지 오류',
            contentText: '추천 장소를 가져오는 데 실패했습니다.',
          ),
        );
      }
    }
  }

  // AddPage_0에서 여행 생성 완료 후 전달된 tourId와 AddPage_2에서 선택한 장소 정보들을 함께 받아 서버에 POST 요청
  Future<void> saveTourCourse(int tourId, List<PlaceInfoBlock> places) async {
    final dio = Dio();
    final baseUrl = 'http://conever.duckdns.org:8000';
    try {
      final accessToken = await getAccessToken();
      // 여행 시작일을 불러오기 위한 GET 요청
      final startDateResponse = await dio.get(
        '$baseUrl/tour/$tourId/',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      final startDate = startDateResponse.data['start_date'];

      // 장소 정보를 서버에 맞는 포맷으로 변환 (name, mapX, mapY, image, address)
      final List<Map<String, dynamic>> courseData = places.map((place) => {
        'name': '<${place.title}>',
        'mapX': place.mapX,
        'mapY': place.mapY,
        'image_url': place.imageUrl,
        'road_address': '<${place.description}>'
      }).toList();

      // 최종 코스 정보를 서버에 저장 요청
      final response = await dio.post(
        '$baseUrl/tour/course/',
        data: {
          'tour_id': '$tourId',
          'date': startDate,
          'places': courseData,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      // 저장 성공 시 콘솔에 출력
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('경로 저장 완료');
      }
      else {
        print('저장 실패: ${response.statusCode}');
      }
    }
    catch (e) {
      print('예외 발생: $e');
    }
  }

  // PlanCard와 동일 크기의 빈 카드 UI, 탭 시 새 여행 생성 페이지로 이동
  Widget _buildEmptyPlanCard(double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AddPage_0(),
          ),
        );
      },
      child: Container(
        width: width * 0.8,
        height: height * 0.394,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 37.5, color: Color(0xFFB5B5B5),),
              SizedBox(height: height * 0.01),
              const Text(
                '이런, 여행이 없어요🧐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB5B5B5),
                ),
              ),
              const Text(
                '여행을 추가해주세요!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB5B5B5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: height * 0.1,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.066,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.024),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _currentUsername ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                  ),
                                ),
                                const Text(
                                  '님',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                                "오늘도 좋은 하루에요 👋",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                )
                            ),
                            SizedBox(height: height * 0.024),
                            const Text(
                              '⏰ 다가오는 일정',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: height * 0.012),
                            // ⬇️ PlanCard 위젯: 여행 카드의 크기를 반응형으로 지정, _nearestPlan에서 동적 데이터 사용
                            Center(
                              // 로딩 중에는 PlanCard와 동일한 디자인의 빈 카드 표시
                              child: _isLoading
                                  ? // 로딩 플레이스홀더
                              SizedBox(
                                width: width * 0.8,
                                height: height * 0.394,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: const Color(0xFFF5F5F5),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      width * 0.05,
                                      height * 0.05,
                                      width * 0.05,
                                      height * 0.05,
                                    ),
                                  ),
                                ),
                              )
                                  : (
                                      _nearestPlan != null
                                          ? PlanCard(
                                              tour_id: _nearestPlan!['id'],
                                              title: _nearestPlan!['title'] ?? '제목 없음',
                                              startDate: _nearestPlan!['start_date'] ?? '',
                                              endDate: _nearestPlan!['end_date'] ?? '',
                                              size_h: height * 0.394,
                                              size_w: width * 0.8,
                                            )
                                          : _buildEmptyPlanCard(width, height)
                                    ),
                            ),
                            SizedBox(height: height * 0.06),
                            Center(
                              child: ProceedButton(
                                size_w: width * 0.586,
                                size_h: height * 0.055,
                                text: "✨ 새로운 장소 탐험하기",
                                fontSize_: 15,
                                fontWeight_: FontWeight.bold,
                                onTap: _scrollToBottom,
                              ),
                            ),
                            // 트렌딩 버튼 하단에 여백 추가
                            SizedBox(height: height * 0.09),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                              child: const Text(
                                "오늘\n이런 곳은 어떤가요?",
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.04),
                            // 장소 추천 영역: 단일 Column으로 조건부 children 렌더링
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_recommendedPlace != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      _recommendedPlace!['image1'],
                                      width: width * 0.87,
                                      height: height * 0.25,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: width * 0.87,
                                          height: height * 0.25,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: width * 0.093,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 17, color: Colors.black),
                                      SizedBox(width: width * 0.013),
                                      Text(
                                        _recommendedPlace!['title'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.007),
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.053),
                                    child: Text(
                                      (_recommendedPlace?['title'] != null && _recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                          ? "${_recommendedPlace?['title']}은(는) ${(_recommendedPlace?['address'] as String).split(' ')[1]}의 관광지 입니다.\n${_currentUsername ?? ''} 님의 마음에 드셨으면 좋겠네요!"
                                          : '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.017),
                                  Center(
                                    child: ProceedButton(
                                      size_w: width * 0.5,
                                      size_h: height * 0.05,
                                      text: (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                          ? "${(_recommendedPlace?['address'] as String).split(' ')[1]} 코스 생성하기"
                                          : "코스 생성하기",
                                      fontSize_: 13,
                                      fontWeight_: FontWeight.bold,
                                      onTap: () async {
                                        final String sigun = (_recommendedPlace?['address'] != null && (_recommendedPlace?['address'] as String).split(' ').length > 1)
                                            ? (_recommendedPlace?['address'] as String).split(' ')[1]
                                            : '';
                                        final accessToken = await getAccessToken();
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (_) => AddPage_2(
                                              title: sigun,
                                              tourId: 0,
                                              isSingleDayMode: true, // 싱글모드 명시 -> 트렌딩, 검색창일 경우 true
                                              onSaveCourseCallback: (places) {
                                                Navigator.of(context).push(
                                                  CupertinoPageRoute(
                                                    builder: (_) => AddPage_0(
                                                      onFinishCreation: (int tourId) {
                                                        Navigator.of(context).push(
                                                          CupertinoPageRoute(
                                                            builder: (_) => AddPage_3(
                                                              tour_id: tourId,
                                                            ),
                                                          ),
                                                        );
                                                        saveTourCourse(tourId, places);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ] else ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: width * 0.87,
                                      height: width * 0.55,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Container(
                                    width: width * 0.87,
                                    height: height * 0.08,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04,
                                      vertical: height * 0.012,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '트렌딩 페이지 정보를 받아오고 있습니다...',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.017),
                                  Center(
                                    child: ProceedButton(
                                      size_w: width * 0.5,
                                      size_h: height * 0.05,
                                      text: '가져오는 중...',
                                      fontSize_: 13,
                                      fontWeight_: FontWeight.bold,
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: height * 0.01),

                            // 맨 상단으로 되돌아가기 버튼
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: Icon(
                                  Icons.arrow_drop_up,
                                  color: Colors.grey,
                                  size: width * 0.06,
                                ),
                                label: const Text(
                                  '홈으로 이동',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.092),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 행정구역 검색 기능을 제공하는 앱바, 오버레이 리스트와 연결됨
            SearchAppBar(
              onSaveCourse: saveTourCourse,
            ),
          ],
        ),
      ),
    );
  }
}