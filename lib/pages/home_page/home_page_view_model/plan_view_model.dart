import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../services/access_token/get_access_token_from_refresh_token.dart';
import '../../../services/http/tour/tour_fetcher.dart';
import '../../../services/http/tour/tour_utils.dart';
import '../../../services/http/tour/tour_validator.dart';
import '../../../services/http/user_me.dart';

class PlanViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? currentUsername;
  Map<String, dynamic>? nearestPlan;

  /// 여행 목록을 불러오고, 가장 가까운 여행을 선택
  Future<void> fetchPlans(BuildContext context) async {
    try {
      // 1. 사용자 이름 불러오기
      currentUsername = await UserService.getCurrentUsername(context);

      // 2. 사용자 관련 여행 목록 불러오기
      final userPlans = await TourFetcher.getUserTours(context, currentUsername!);

      // 3. 유효한 여행만 필터링 (만료 or 코스 없는 여행 삭제)
      final validPlans = await TourValidator.filterValidTours(context, userPlans);

      // 4. 가장 가까운 여행 선택
      if (validPlans.isNotEmpty) {
        nearestPlan = TourUtils.pickNearestTour(validPlans);
      } else {
        nearestPlan = null;
      }
    } catch (e) {
      // 5. 토큰 만료 시 갱신 후 재시도
      if (e is DioException && e.response?.statusCode == 403) {
        final result = await getAccessTokenFromRefreshToken();
        if (result == false) return;
        await fetchPlans(context);
        return;
      } else {
        nearestPlan = null;
      }
    } finally {
      isLoading = false;
      notifyListeners(); // 상태 변경 알림
    }
  }
}