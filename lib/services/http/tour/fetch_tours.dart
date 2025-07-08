import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> fetchTours(BuildContext context, int id) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:80/tour/$id/');
    return response.data;
  } catch (e) {
    throw Exception("fetchTourCourses Error: $e");
  }
}