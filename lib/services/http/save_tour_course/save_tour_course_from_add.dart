import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../components/placeinfo_card.dart';
import '../../../components/save_loading_page.dart';
import '../../../pages/add_page/add_page_3.dart';
import '../../dio/authorized_dio.dart';

class SaveTourCourseFromAdd {
  Future<void> saveCourse({
    required BuildContext context,
    required List<MapEntry<String, List<PlaceInfoBlock>>> placeWidgets,
    required int tourId,
  }) async {
    final dio = await getAuthorizedDio(context);
    const baseUrl = 'http://conever.duckdns.org:8000';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: SizedBox(
          width: kIsWeb ? 430 * 0.95 : null,
          child: SaveLoadingView(),
        ),
      ),
    );

    try {
      final _ = await dio.get('$baseUrl/tour/$tourId/');

      for (var entry in placeWidgets) {
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
            'tour_id': '$tourId',
            'date': date,
            'places': courseData
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          print('날짜 $date 저장 실패');
        }
      }

      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddPage_3(tour_id: tourId, accessToken: '',),
        ),
      );
    } catch (e) {
      print('코스 저장 중 오류 발생: $e');
    }
  }
}