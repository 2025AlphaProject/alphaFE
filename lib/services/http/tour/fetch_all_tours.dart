import 'package:flutter/cupertino.dart';
import '../../dio/authorized_dio.dart';

Future<List<dynamic>> fetchAllTours(BuildContext context) async {
  try {
    final dio = await getAuthorizedDio();
    final response = await dio.get('http://3.34.125.36:80/tour/');
    return response.data as List;
  } catch (e) {
    throw Exception("fetchAllTours Error: $e");
  }
}
