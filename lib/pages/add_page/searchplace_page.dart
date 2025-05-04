import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alpha_fe/components/proceed_button.dart';
import 'package:logger/logger.dart';

// 로거 사용을 위한 전역변수 선언
final logger = Logger();

class SearchPlacePage extends StatefulWidget {
  final void Function({
  required String imageUrl,
  required String title,
  required String address,
  required double mapX,
  required double mapY,
  }) onPlaceSelected;

  const SearchPlacePage({Key? key, required this.onPlaceSelected}) : super(key: key);

  @override
  State<SearchPlacePage> createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  final TextEditingController _searchController = TextEditingController();
  late NaverMapController _mapController;
  final Dio _dio = Dio();
  List<Map<String, dynamic>> _places = [];
  Map<String, dynamic>? _selectedPlace;
  final List<NMarker> _markers = [];

  // 네이버맵 sdk 초기화 함수
  Future<void> initNaverMapSdk() async {
    await FlutterNaverMap().init(
        clientId: dotenv.env['NAVER_DYNAMIC_MAP'],

        // 인증 실패 시 실행될 콜백
        onAuthFailed: (ex) =>
        switch (ex) {
          NQuotaExceededException(:final message) =>
              logger.d('사용량 초과 (message: $message)'),
          NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException() =>
              logger.d('인증 실패: $ex'),
        }
    );
  }

  // .env 파일에서 Kakao REST API 키 불러오기
  final String _kakaoRestKey = dotenv.env['KAKAO_REST_KEY']!;

  // 장소 검색: Kakao Local API 이용
  Future<void> _searchPlace(String query) async {
    const String url = 'https://dapi.kakao.com/v2/local/search/keyword.json';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'query': query},
        options: Options(headers: {'Authorization': 'KakaoAK $_kakaoRestKey'}),
      );

      final docs = response.data['documents'] as List<dynamic>;

      // 서울 지역 주소만 필터링하여 Map<String, dynamic>으로 변환
      final seoulDocs = docs.where((doc) {
        final addr = doc['address_name'] ?? doc['road_address_name'] ?? '';
        return addr.startsWith('서울');
      }).map((e) => e as Map<String, dynamic>).toList();

      setState(() {
        _places = seoulDocs;
        _selectedPlace = null;
      });

      // 마커 업데이트 수행
      await _updateMarkers();
    } catch (e) {
      // 검색 실패 시 안내 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연결이 불안정합니다')),
      );
    }
  }


  // 지도 마커 업데이트: 오류 시 SDK 초기화 및 재시도
  Future<void> _updateMarkers() async {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    try {
      for (final marker in _markers) {
        _mapController.deleteOverlay(
          NOverlayInfo(type: NOverlayType.marker, id: marker.info.id),
        );
      }
      _markers.clear();

      for (final place in _places) {
        final marker = NMarker(
          id: place['id'],
          position: NLatLng(
            double.parse(place['y']),
            double.parse(place['x']),
          ),
        );
        _mapController.addOverlay(marker);
        _markers.add(marker);
      }

      if (_places.isNotEmpty) {
        _mapController.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(
              double.parse(_places[0]['y']),
              double.parse(_places[0]['x']),
            ),
            zoom: width > 500 ? 13 : 14,
          ),
        );
      }
    } catch (e) {
      int retryCount = 0;
      bool initialized = false;
      while (retryCount < 3 && !initialized) {
        try {
          await initNaverMapSdk();
          initialized = true;
        } catch (_) {
          retryCount++;
        }
      }
      if (!initialized && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연결이 불안정합니다')),
        );
      } else if (initialized) {
        await _updateMarkers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),

        // 검색창
        title: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: width * 0.04),
          decoration: InputDecoration(
            hintText: '서울 내의 장소를 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),

              // 검색 버튼 탭 시 키보드 닫고 검색 실행
              onPressed: () {
                FocusScope.of(context).unfocus();
                _searchPlace(_searchController.text);
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 지도 영역 배경 흰색
              Container(
                width: double.infinity,
                height: height * 0.35,
                color: const Color(0xFFFFFFFF),
                child: NaverMap(
                  onMapReady: (controller) {
                    _mapController = controller;
                  },
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.5665, 126.9780),
                      zoom: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.015),

              // 검색 결과 리스트
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  child: ListView.separated(
                    itemCount: _places.length,
                    separatorBuilder: (context, index) =>
                        Divider(
                          color: Colors.grey.shade300,
                          height: 1,
                        ),
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      final isSelected = _selectedPlace?['id'] == place['id'];

                      // 선택 시 텍스트 색상
                      final titleColor =
                      isSelected ? Colors.black : Colors.grey.shade600;
                      final subtitleColor =
                      isSelected ? Colors.black : Colors.grey.shade600;

                      return ListTile(
                        // 기본 흰색, 선택 시 회색
                        tileColor: Colors.white,
                        selected: isSelected,
                        selectedTileColor: Colors.grey.shade200,
                        title: Text(
                          place['place_name'] ?? '',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          place['address_name'] ?? '',
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: subtitleColor,
                          ),
                        ),

                        // 장소 선택 및 카메라 이동
                        onTap: () async {
                          setState(() {
                            _selectedPlace = place;
                          });

                          try {
                            _mapController.updateCamera(
                              NCameraUpdate.scrollAndZoomTo(
                                target: NLatLng(
                                  double.parse(place['y']),
                                  double.parse(place['x']),
                                ),
                                zoom: width > 500 ? 14 : 15,
                              ),
                            );
                          } catch (_) {
                            int retry = 0;
                            bool success = false;
                            while (retry < 3 && !success) {
                              try {
                                await initNaverMapSdk();
                                _mapController.updateCamera(
                                  NCameraUpdate.scrollAndZoomTo(
                                    target: NLatLng(
                                      double.parse(place['y']),
                                      double.parse(place['x']),
                                    ),
                                    zoom: width > 500 ? 14 : 15,
                                  ),
                                );
                                success = true;
                              } catch (_) {
                                retry++;
                              }
                            }
                            if (!success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('연결이 불안정합니다'),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // 장소 선택 시 하단 오버레이 버튼
          if (_selectedPlace != null)
            Positioned(
              bottom: height * 0.02,
              left: width * 0.235,
              width: width * 0.53,
              height: height * 0.055,
              child: ProceedButton(
                fontSize_: width * 0.037,
                fontWeight_: FontWeight.bold,
                text: "이 장소 추가하기",
                onTap: () {
                  widget.onPlaceSelected(
                    imageUrl: _selectedPlace!['thumbnail'] ?? '',
                    title: _selectedPlace!['place_name'] ?? '제목 없음',
                    address: _selectedPlace!['address_name'] ?? '주소 없음',
                    mapX: double.parse(_selectedPlace!['x']),
                    mapY: double.parse(_selectedPlace!['y']),
                  );
                  Navigator.pop(context);
                },
                size_w: width * 0.53,
                size_h: height * 0.055,
              ),
            ),
        ],
      ),
    );
  }
}