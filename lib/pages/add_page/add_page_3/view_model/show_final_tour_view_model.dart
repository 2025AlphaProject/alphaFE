import 'package:flutter/material.dart';

import '../../../../services/dio/authorized_dio.dart';

class ShowFinalTourViewModel extends ChangeNotifier {
  Map<String, dynamic>? tourData;
  bool isLoading = true;

  Future<void> fetchTourData(BuildContext context, int tourId) async {
    isLoading = true;
    notifyListeners();

    try {
      final dio = await getAuthorizedDio();
      final response = await dio.get('http://3.34.125.36:80/tour/$tourId/');
      tourData = response.data;
    } catch (e) {
      print('🚫 tour data fetch error: $e');
      tourData = null;
    }

    isLoading = false;
    notifyListeners();
  }
}