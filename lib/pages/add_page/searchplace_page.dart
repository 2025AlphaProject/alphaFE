import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:dio/dio.dart';

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

  final String _kakaoRestKey = '8573ba89ca009d06cf305343b24140e1'; // TODO: env 이용하도록 교체해야함

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
          _places = documents.cast<Map<String, dynamic>>();
          _selectedPlace = null;
        });

        _updateMarkers();
      }
    } catch (e) {
      print("❌ 장소 검색 실패: $e");
    }
  }

  void _updateMarkers() {
    for (final marker in _markers) {
      _mapController.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: marker.info.id));
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
          zoom: 14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '장소를 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchPlace(_searchController.text),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🗺 지도 영역
          SizedBox(
            height: 300,
            child: NaverMap(
              onMapReady: (controller) {
                _mapController = controller;
              },
              options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(37.5665, 126.9780), // 서울 시청
                  zoom: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 📋 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                final isSelected = _selectedPlace?['id'] == place['id'];
                return ListTile(
                  title: Text(place['place_name'] ?? ''),
                  subtitle: Text(place['address_name'] ?? ''),
                  tileColor: isSelected ? Colors.grey.shade300 : null,
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
                        zoom: 15,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ "이 장소 추가하기" 버튼
          if (_selectedPlace != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onPlaceSelected(
                    imageUrl: _selectedPlace!['thumbnail'] ?? '', // 실제 필드명은 API 구조에 맞게 수정
                    title: _selectedPlace!['place_name'] ?? '제목 없음',
                    address: _selectedPlace!['address_name'] ?? '주소 없음',
                    mapX: double.parse(_selectedPlace!['x']),
                    mapY: double.parse(_selectedPlace!['y']),
                  );
                  Navigator.pop(context);
                },
                child: const Text("이 장소 추가하기"),
              ),
            ),
        ],
      ),
    );
  }
}