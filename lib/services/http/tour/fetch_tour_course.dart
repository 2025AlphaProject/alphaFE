import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> fetchTourCourse(BuildContext context, int tourId) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get("http://conever.duckdns.org:8000/tour/course/$tourId/");
    return response.data;
  } catch (e) {
    throw Exception("getCourse Error: $e");
  }
}