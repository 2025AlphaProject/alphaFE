import 'package:flutter/material.dart';

import '../../../../services/network/tour_service/tour_service.dart';

class TourCreateViewModel with ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  Future<void> registerTour(BuildContext context, String title, DateTimeRange range) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await TourService.registerTour(context, title, range);
      if (result != null) {
        isSuccess = true;
        // tourId 등도 필요 시 저장
      } else {
        errorMessage = "등록 실패";
      }
    } catch (e) {
      errorMessage = "예외 발생: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}