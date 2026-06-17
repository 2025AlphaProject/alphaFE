import 'package:alpha_fe/services/dio/authorized_dio.dart';

Future<void> deleteTourById(int id) async {
  try {
    final dio = await getAuthorizedDio();
    await dio.delete('http://3.34.125.36:80/tour/$id/');
  } catch (e) {
    throw Exception("deleteTourById Error: $e");
  }
}