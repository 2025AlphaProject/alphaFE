import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../pages/add_page/add_page_2/models/tour_info.dart';
import '../../dio/authorized_dio.dart';
class ShowTourCourseApi {
  final Dio _dio = Dio();
  final String baseUrl = 'http://conever.duckdns.org:80';

  Future<int?> fetchUserId(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
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
        final dio = await getAuthorizedDio(context);
        final response = await dio.get('$baseUrl/tour/$tourId/');
        return TourInfo.fromJson(response.data, userId);
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }
}