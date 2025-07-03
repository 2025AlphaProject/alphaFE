import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<List<dynamic>> fetchTourCourses(BuildContext context, String id) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/tour/course/$id/');
    return response.data;
  } catch (e) {
    throw Exception("fetchTourCourses Error: $e");
  }
}

Future<void> deleteTourById(BuildContext context, String id) async {
  try {
    final dio = await getAuthorizedDio(context);
    await dio.delete('http://conever.duckdns.org:8000/tour/$id/');
  } catch (e) {
    throw Exception("deleteTourById Error: $e");
  }
}