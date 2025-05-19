import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<bool> addUserToTour({
  required BuildContext context,
  required int tourId,
  required String sub,
}) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.post(
      'http://conever.duckdns.org:8000/tour/add_traveler/',
      data: {
        'add_traveler_sub': sub,
        'travel_id': tourId,
      },
    );
    return response.statusCode == 201;
  } catch (e) {
    print('Error adding user: $e');
    return false;
  }
}