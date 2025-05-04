import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:alpha_fe/components/proceed_button.dart'; // 진행 버튼 컴포넌트 임포트

class SearchPlacePage extends StatefulWidget {

  // 콜백 함수: 사용자가 장소를 선택했을 때 호출됨
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
  late NaverMapController _mapController; // 네이버 지도 컨트롤러
  final Dio _dio = Dio(); // HTTP 요청을 위한 Dio 인스턴스
  List<Map<String, dynamic>> _places = []; // 검색 결과 장소 리스트
  Map<String, dynamic>? _selectedPlace; // 현재 선택된 장소 정보
  final List<NMarker> _markers = []; // 지도에 표시할 마커 리스트

  // .env 파일에서 Kakao REST API 키를 불러옴
  final String _kakaoRestKey = dotenv.env['KAKAO_REST_KEY']!; // TODO: 카카오 디벨로퍼에서 REST API키를 복사해 자신의 .env에 추가할 것

  // 장소 검색 함수: 카카오 로컬 API를 이용해 키워드로 장소 검색
  Future<void> _searchPlace(String query) async {
    const String url = 'https://dapi.kakao.com/v2/local/search/keyword.json';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {'query': query},
        options: Options(headers: {'Authorization': 'KakaoAK $_kakaoRestKey'}),
      );

      final documents = response.data['documents'];
      if (documents != null && documents is List) {
        setState(() {
          _places = documents.cast<Map<String, dynamic>>(); // 검색 결과 저장
          _selectedPlace = null; // 이전 선택 초기화
        });

        _updateMarkers(); // 지도에 마커 업데이트
      }
    } catch (e) {
      print("❌ 장소 검색 실패: $e"); // 에러 발생 시 로그 출력
    }
  }

  // 지도 마커를 업데이트하는 함수
  void _updateMarkers() {
    final width = MediaQuery.of(context).size.width;
    // 기존 마커 삭제
    for (final marker in _markers) {
      _mapController.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: marker.info.id));
    }

    _markers.clear();

    // 검색된 장소마다 마커 생성 및 지도에 추가
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

    // 첫 번째 장소 위치로 지도 카메라 이동 및 확대
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
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),

        // 검색 입력창
        title: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: width * 0.04),
          decoration: InputDecoration(
            hintText: '장소를 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),

              // 검색 버튼 탭 시 키보드 닫고 장소 검색 실행
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
                    _mapController = controller; // 지도 컨트롤러 초기화
                  },
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.5665, 126.9780), // 초기 위치: 서울 시청
                      zoom: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.015),

              // 검색 결과 리스트: 검색된 장소들을 리스트뷰로 표시
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF), // 리스트 배경 흰색
                  child: ListView.separated(
                    // 하단 버튼 오버레이 공간 확보 패딩 제거
                    itemCount: _places.length,
                    // 항목 사이에 얇은 구분선 추가
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade300,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final place = _places[index];
                      final isSelected = _selectedPlace?['id'] == place['id'];

                      // 선택된 경우 텍스트 색상 변경
                      final titleColor = isSelected ? Colors.black : Colors.grey.shade600;
                      final subtitleColor = isSelected ? Colors.black : Colors.grey.shade600;

                      return Material(
                        // 일반 상태는 흰색, 선택 시 회색으로 배경색 적용
                        color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            place['place_name'] ?? '',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: titleColor,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Text(
                            place['address_name'] ?? '',
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: subtitleColor,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedPlace = place;
                            });

                            _mapController.updateCamera(
                              NCameraUpdate.scrollAndZoomTo(
                                target: NLatLng(
                                  double.parse(place['y']),
                                  double.parse(place['x']),
                                ),
                                zoom: width > 500 ? 14 : 15,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // 선택된 장소가 있을 때만 하단에 버튼 오버레이
          if (_selectedPlace != null)
            Positioned(
              // 버튼만 해당 영역을 차지하도록 너비와 높이를 지정
              bottom: height * 0.02,
              left: width * 0.235,
              width: width * 0.53,
              height: height * 0.055,
              child:ProceedButton(
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