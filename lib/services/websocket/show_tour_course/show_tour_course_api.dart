import 'package:flutter/material.dart';

import '../../../pages/add_page/add_page_2/models/tour_info.dart';
import '../../dio/authorized_dio.dart';
class ShowTourCourseApi {
  final String baseUrl = 'http://3.34.125.36:80';

  Future<int?> fetchUserId() async {
    final dio = await getAuthorizedDio();
    for (int i = 0; i < 3; i++) {
      try {
        final response = await dio.get('$baseUrl/user/me/');
        return response.data['sub'];
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  Future<TourInfo?> fetchTourInfo(BuildContext context, int tourId, int userId) async {
    for (int i = 0; i < 3; i++) {
      try {
        final dio = await getAuthorizedDio();
        final response = await dio.get('$baseUrl/tour/$tourId/');
        return TourInfo.fromJson(response.data, userId);
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }
}