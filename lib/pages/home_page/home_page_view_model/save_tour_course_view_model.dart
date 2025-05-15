import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../components/placeinfo_card.dart';
import '../../../services/dio/authorized_dio.dart';
import '../../../services/http/save_tour_course/save_tour_course_from_home.dart';

class TourCourseViewModel with ChangeNotifier {
  bool isSaving = false;
  bool? saveSuccess;

  Future<void> save(BuildContext context, int tourId, List<PlaceInfoBlock> places) async {
    isSaving = true;
    notifyListeners();

    final dio = await getAuthorizedDio(context);

    try {
      await SaveTourCourseFromHome(dio as BuildContext, tourId, places);
      saveSuccess = true;
    } catch (_) {
      saveSuccess = false;
    }

    isSaving = false;
    notifyListeners();
  }
}