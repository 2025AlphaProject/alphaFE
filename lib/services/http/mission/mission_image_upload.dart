import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<Response> MissionImageUpload(BuildContext context, String imagePath, int tdpId) async {
  final dio = await getAuthorizedDio(context);

  final formData = FormData.fromMap({
    'travel_days_id': tdpId.toString(),
    'image': await MultipartFile.fromFile(imagePath),
  });

  try {
    final response = await dio.post(
      'http://conever.duckdns.org:8000/mission/image_upload/',
      data: formData,
    );
    return response;
  } catch (e) {
    throw Exception("MissionImageUpload Error: $e");
  }
}