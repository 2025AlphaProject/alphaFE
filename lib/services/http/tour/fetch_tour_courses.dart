import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<List<dynamic>> fetchTourCourses(BuildContext context, int id) async {
  try {
    final dio = await getAuthorizedDio();
    final response = await dio.get('http://3.34.125.36:80/tour/course/$id/');
    return response.data;
  } catch (e) {
    throw Exception("fetchTourCourses Error: $e");
  }
}