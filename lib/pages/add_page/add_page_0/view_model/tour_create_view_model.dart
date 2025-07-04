import 'package:flutter/material.dart';

import '../../../../services/http/tour/register_tour.dart';

class TourCreateViewModel with ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  Future<void> registerTour(
    BuildContext context,
    String title,
    DateTimeRange range, {
    Function(int)? onSuccess,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await RegisterTour(context, title, range);
      if (result != null) {
        isSuccess = true;
        onSuccess?.call(result); // Pass tourId if needed
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