import 'package:alpha_fe/services/dio/authorized_dio.dart';

Future<bool> addUserToTour({
  required int tourId,
  required String sub,
}) async {
  try {
    final dio = await getAuthorizedDio();
    final response = await dio.post(
      'http://3.34.125.36:80/tour/add_traveler/',
      data: {
        'add_traveler_sub': sub,
        'travel_id': tourId,
      },
    );
    return response.statusCode == 201;
  } catch (e) {
    throw Exception('addUserToTour Error: $e');  //TODO: stack 을 사용해서 Firebase Crashlytics 아니면 Sentry 로 로그 수집을 할 수 있다.
  }
}