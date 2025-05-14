import 'dart:ui';

import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_response_handler.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_state.dart';
import 'package:flutter/cupertino.dart';

import '../../../../services/websocket/show_tour_course/show_tour_course_api.dart';
import '../../../../services/websocket/show_tour_course/show_tour_course_websocket.dart';
import '../models/tour_info.dart';

class ShowTourCourseRequestManager {
  final ShowTourCourseApi apiService;
  final ShowTourCourseWebsocket socketService;

  ShowTourCourseRequestManager({
    required this.apiService,
    required this.socketService,
  });

  Future<void> fetch({
    required BuildContext context,
    required int tourId,
    required String areaName,
    required bool isSingleDayMode,
    required bool isWeb,
    required ShowTourCourseState state,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    state.reset();

    final userId = await apiService.fetchUserId(context);
    if (userId == null) return onError('사용자 정보를 불러올 수 없습니다.');

    final tourInfo = isSingleDayMode
        ? TourInfo(userId: userId, startDate: DateTime.now(), endDate: DateTime.now())
        : await apiService.fetchTourInfo(context, tourId, userId);

    if (tourInfo == null) return onError('여행 날짜 정보를 불러올 수 없습니다.');

    socketService.connect(
      userId: userId,
      areaName: areaName,
      days: tourInfo.numberOfDays,
      onData: (data) {
        final handler = ShowTourCourseResponseHandler(
          isWeb: isWeb,
          areaName: areaName,
          isSingleDayMode: isSingleDayMode,
          state: state,
          tourInfo: tourInfo,
        );
        handler.handle(data);

        if (!state.hasError) onSuccess();
        else onError(state.errorMessage);
      },
      onError: () {
        onError('WebSocket 연결 실패');
      },
    );
  }
}