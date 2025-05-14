import 'package:dio/dio.dart';

Future<Dio> getUnauthorizedDio() async {
  final dio = Dio();
  dio.options.headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  return dio;
}