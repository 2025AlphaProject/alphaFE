import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:dio/dio.dart';

Future<Response> MissionImageUpload(String imagePath, int tdpId) async {
  final dio = await getAuthorizedDio();

  final formData = FormData.fromMap({
    'travel_days_id': tdpId.toString(),
    'image': await MultipartFile.fromFile(imagePath),
  });

  try {
    final response = await dio.post(
      'http://3.34.125.36:80/mission/image_upload/',
      data: formData,
    );
    return response;
  } catch (e) {
    throw Exception("MissionImageUpload Error: $e");
  }
}