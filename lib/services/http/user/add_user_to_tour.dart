import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<bool> AddUserToTour({
  required BuildContext context,
  required String sub,
  required int tourId,
}) async {
  final dio = await getAuthorizedDio(context);
  final response = await dio.post(
    'http://conever.duckdns.org:8000/tour/add_traveler/',
    data: {
      'add_traveler_sub': sub,
      'travel_id': tourId,
    },
  );
  return response.statusCode == 201;
}