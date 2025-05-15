import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_state.dart';

import '../models/place_info.dart';
import '../models/tour_info.dart';

class ShowTourCourseResponseHandler {
  final bool isWeb;
  final String areaName;
  final bool isSingleDayMode;
  final ShowTourCourseState state;
  final TourInfo tourInfo;

  ShowTourCourseResponseHandler({
    required this.isWeb,
    required this.areaName,
    required this.isSingleDayMode,
    required this.state,
    required this.tourInfo,
  });

  void handle(dynamic data) {
    if (data["status"] == "OK" || data["result"] == null || state.receivedData) return;
    if (data["status"] != "SUCCESS") {
      state.hasError = true;
      state.errorMessage = '코스 생성 실패';
      state.isLoading = false;
      return;
    }

    state.receivedData = true;
    final result = <String, List<PlaceInfo>>{};

    if (isSingleDayMode) {
      final list = (data["result"][0] as List)
          .where((e) => (e["address"]?.toString().contains(areaName) ?? false))
          .map((e) => PlaceInfo.fromJson(e, isWeb: isWeb))
          .take(5)
          .toList();
      result[areaName] = list;
    } else {
      final dates = tourInfo.dateRange;
      for (int i = 0; i < dates.length && i < data["result"].length; i++) {
        final list = (data["result"][i] as List)
            .where((e) => (e["address"]?.toString().contains(areaName) ?? false))
            .map((e) => PlaceInfo.fromJson(e, isWeb: isWeb))
            .take(5)
            .toList();
        if (list.isNotEmpty) {
          result[dates[i]] = list;
        }
      }
    }

    state.placeMap = result;
    state.isLoading = false;
  }
}