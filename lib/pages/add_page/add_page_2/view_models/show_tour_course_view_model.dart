import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_request_manager.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_state.dart';
import 'package:flutter/material.dart';

import '../../../../services/websocket/show_tour_course/show_tour_course_api.dart';
import '../../../../services/websocket/show_tour_course/show_tour_course_websocket.dart';
import '../models/place_info.dart';

class ShowTourCourseViewModel extends ChangeNotifier {
  final ShowTourCourseApi _apiService;
  final ShowTourCourseWebsocket _socketService;

  final ShowTourCourseState _state = ShowTourCourseState();
  late final ShowTourCourseRequestManager _requestManager;

  ShowTourCourseViewModel({
    required ShowTourCourseApi apiService,
    required ShowTourCourseWebsocket socketService,
  })  : _apiService = apiService,
        _socketService = socketService {
    _requestManager = ShowTourCourseRequestManager(
      apiService: _apiService,
      socketService: _socketService,
    );
  }

  // 📦 외부에서 접근 가능한 상태 getter
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String get errorMessage => _state.errorMessage;
  Map<String, List<PlaceInfo>> get placeMap => _state.placeMap;

  // 📡 추천 요청 실행
  Future<void> fetchCourseRecommendation({
    required int tourId,
    required String areaName,
    required bool isWeb,
    required BuildContext context,
  }) async {
    await _requestManager.fetch(
      context: context,
      tourId: tourId,
      areaName: areaName,
      isWeb: isWeb,
      state: _state,
      onSuccess: notifyListeners,
      onError: (msg) {
        _state.hasError = true;
        _state.errorMessage = msg;
        _state.isLoading = false;
        notifyListeners();
      },
    );
  }

  // 💡 UI에서 다시 초기화하고 싶을 때
  void reset() {
    _state.reset();
    notifyListeners();
  }
}