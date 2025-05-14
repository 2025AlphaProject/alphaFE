import 'package:dio/dio.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Dio> getAuthorizedDio(BuildContext context) async {
  final accessToken = context.read<AuthProvider>().accessToken;
  final dio = Dio();
  dio.options.headers = {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  return dio;
}
