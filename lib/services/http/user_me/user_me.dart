import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

class UserService {
  Future<List<Map<String, dynamic>>> fetchAllUsers(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/user/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> fetchMyInfo(BuildContext context) async {
    final dio = await getAuthorizedDio(context);
    final response = await dio.get('http://conever.duckdns.org:8000/user/me/');
    return response.data;
  }

  Future<bool> addUserToTour(BuildContext context, String sub, int tourId) async {
    final dio = await getAuthorizedDio(context);
    final response = await dio.post(
      'http://conever.duckdns.org:8000/tour/add_traveler/',
      data: {
        'add_traveler_sub': sub,
        'travel_id': tourId,
      },
    );
    return response.statusCode == 201;
  }
}