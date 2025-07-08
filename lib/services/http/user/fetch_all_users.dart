import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<List<Map<String, dynamic>>> FetchAllUsers ({
  required BuildContext context,
}) async {
  try {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:80/user/');
    return List<Map<String, dynamic>>.from(response.data);
  } catch (e) {
    throw Exception("FetchAllUsers Error: $e");
  }
}