import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<void> editTourName(BuildContext context, int id, String editedTourName) async {
  try {
    final dio = await getAuthorizedDio(context);
    await dio.put(
        'http://conever.duckdns.org:80/tour/$id/',
      data: {
          'tour_name': editedTourName,
      }
    );
  } catch (e) {
    throw Exception("deleteTourById Error: $e");
  }
}