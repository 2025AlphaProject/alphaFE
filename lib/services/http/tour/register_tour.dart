import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<int> RegisterTour(BuildContext context, String title, DateTimeRange range) async {
  final dio = await getAuthorizedDio(context);
  final start = "${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}";
  final end = "${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}";

  final response = await dio.post(
    'http://conever.duckdns.org:80/tour/',
    data: {
      'tour_name': title,
      'start_date': start,
      'end_date': end,
    },
  );

  if (response.statusCode == 201) {
    return response.data['id'];
  } else {
    throw Exception("RegisterTour not 201");
  }
}
