import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';

Future<void> deleteTourById(BuildContext context, String id) async {
  try {
    final dio = await getAuthorizedDio(context);
    await dio.delete('http://conever.duckdns.org:80/tour/$id/');
  } catch (e) {
    throw Exception("deleteTourById Error: $e");
  }
}