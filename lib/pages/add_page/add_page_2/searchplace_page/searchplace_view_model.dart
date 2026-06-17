import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

final logger = Logger();

class SearchPlaceViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  late NaverMapController mapController;
  final Dio dio = Dio();
  List<Map<String, dynamic>> places = [];
  Map<String, dynamic>? selectedPlace;
  final List<NMarker> markers = [];

  final String kakaoRestKey = dotenv.env['KAKAO_REST_KEY']!;
  final String? naverClientId = dotenv.env['NAVER_DYNAMIC_MAP'];

  Future<void> initNaverMapSdk() async {
    await FlutterNaverMap().init(
        clientId: naverClientId,
        onAuthFailed: (ex) =>
        switch (ex) {
          NQuotaExceededException(:final message) => logger.d('사용량 초과 (message: $message)'),
          NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException() => logger.d('인증 실패: $ex'),
        }
    );
  }

  Future<List<Map<String, dynamic>>> searchPlace(String query) async {
    const String url = 'https://dapi.kakao.com/v2/local/search/keyword.json';
    try {
      final response = await dio.get(
        url,
        queryParameters: {'query': query},
        options: Options(headers: {'Authorization': 'KakaoAK $kakaoRestKey'}),
      );

      final docs = response.data['documents'] as List<dynamic>;

      final seoulDocs = docs.where((doc) {
        final addr = doc['road_address_name'] ?? '';
        return addr.startsWith('서울');
      }).map((e) {
        final modified = Map<String, dynamic>.from(e);
        if (modified['road_address_name'] != null && modified['road_address_name'].startsWith('서울')) {
          modified['road_address_name'] = modified['road_address_name'].replaceFirst('서울', '서울특별시');
        }
        return modified;
      }).toList();

      places = seoulDocs;
      selectedPlace = null;
      notifyListeners();
      return seoulDocs;
    } catch (e) {
      logger.e('장소 검색 실패: $e');
      rethrow;
    }
  }

  Future<void> updateMarkers(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) width = 430;
    try {
      for (final marker in markers) {
        mapController.deleteOverlay(
          NOverlayInfo(type: NOverlayType.marker, id: marker.info.id),
        );
      }
      markers.clear();

      for (final place in places) {
        final marker = NMarker(
          id: place['id'],
          position: NLatLng(
            double.parse(place['y']),
            double.parse(place['x']),
          ),
        );
        mapController.addOverlay(marker);
        markers.add(marker);
      }

      if (places.isNotEmpty) {
        mapController.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(
              double.parse(places[0]['y']),
              double.parse(places[0]['x']),
            ),
            zoom: width > 500 ? 13 : 14,
          ),
        );
      }
    } catch (e) {
      logger.e('마커 업데이트 실패: $e');
      rethrow;
    }
  }

  void selectPlace(Map<String, dynamic> place) {
    selectedPlace = place;
    notifyListeners();
  }

  void setMapController(NaverMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void clear() {
    places = [];
    selectedPlace = null;
    markers.clear();
    searchController.clear();
    notifyListeners();
  }
}