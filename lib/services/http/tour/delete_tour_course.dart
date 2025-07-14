import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<void> deleteTourCourse(BuildContext context, int id, String targetDate) async {
  try {
    final dio = await getAuthorizedDio();
    await dio.delete(
        'http://3.34.125.36:80/tour/course/$id/',
      data: {
          "target_date": targetDate
      }
    );
  } catch (e) {
    throw Exception("fetchTourCourses Error: $e");
  }
}