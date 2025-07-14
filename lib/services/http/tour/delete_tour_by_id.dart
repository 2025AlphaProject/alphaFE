import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<void> deleteTourById(BuildContext context, int id) async {
  try {
    final dio = await getAuthorizedDio();
    await dio.delete('http://3.34.125.36:80/tour/$id/');
  } catch (e) {
    throw Exception("deleteTourById Error: $e");
  }
}