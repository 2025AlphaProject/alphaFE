import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          zoom: 14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // 검색 입력창
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '장소를 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchPlace(_searchController.text), // 검색 아이콘 탭할 시 장소 검색 실행
            ),
          ),
        ),
      ),
      body: Column(
        children: [

          // 지도 영역: 네이버 지도 위젯
          SizedBox(
            height: 300,
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
          const SizedBox(height: 12),

          // 검색 결과 리스트: 검색된 장소들을 리스트뷰로 표시
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                final isSelected = _selectedPlace?['id'] == place['id']; // 선택된 장소인지 여부
                return ListTile(
                  title: Text(place['place_name'] ?? ''),
                  subtitle: Text(place['address_name'] ?? ''),
                  tileColor: isSelected ? Colors.grey.shade300 : null, // 선택된 항목 배경색 변경
                  onTap: () {
                    setState(() {
                      _selectedPlace = place; // 선택된 장소 저장
                    });

                    // 선택된 장소 위치로 지도 이동 및 확대
                    _mapController.updateCamera(
                      NCameraUpdate.scrollAndZoomTo(
                        target: NLatLng(
                          double.parse(place['y']),
                          double.parse(place['x']),
                        ),
                        zoom: 15,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // "이 장소 추가하기" 버튼: 선택된 장소가 있을 때만 표시
          if (_selectedPlace != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {

                  // 선택된 장소 정보를 콜백 함수로 전달
                  widget.onPlaceSelected(
                    imageUrl: _selectedPlace!['thumbnail'] ?? '', // TODO: 대체 이미지로 변경 필요
                    title: _selectedPlace!['place_name'] ?? '제목 없음',
                    address: _selectedPlace!['address_name'] ?? '주소 없음',
                    mapX: double.parse(_selectedPlace!['x']),
                    mapY: double.parse(_selectedPlace!['y']),
                  );
                  Navigator.pop(context); // 이전 화면(add_page_2)으로 돌아감
                },
                child: const Text("이 장소 추가하기"),
              ),
            ),
        ],
      ),
    );
  }
}