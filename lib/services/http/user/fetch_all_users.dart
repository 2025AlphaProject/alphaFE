import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<List<Map<String, dynamic>>> FetchAllUsers ({
  required BuildContext context,
}) async {
  try {
    final dio = await getAuthorizedDio();
    final response = await dio.get('http://3.34.125.36:80/user/');
    return List<Map<String, dynamic>>.from(response.data);
  } catch (e) {
    throw Exception("FetchAllUsers Error: $e");
  }
}