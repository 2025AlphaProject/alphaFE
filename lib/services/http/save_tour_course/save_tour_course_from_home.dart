import 'package:flutter/material.dart';
import 'package:alpha_fe/services/dio/authorized_dio.dart';
import '../../../components/placeinfo_card.dart';

Future<void> SaveTourCourseFromHome(BuildContext context, int tourId, List<PlaceInfoBlock> places) async {
  try {
    final dio = await getAuthorizedDio(context);
    final baseUrl = 'http://conever.duckdns.org:8000';

    // 여행 시작일을 불러오기 위한 GET 요청
    final startDateResponse = await dio.get('$baseUrl/tour/$tourId/');
    final startDate = startDateResponse.data['start_date'];

    // 장소 정보를 서버에 맞는 포맷으로 변환
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
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('경로 저장 완료');
    } else {
      print('저장 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('예외 발생: $e');
  }
}