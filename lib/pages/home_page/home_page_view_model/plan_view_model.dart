import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../services/access_token/get_access_token_from_refresh_token.dart';
import '../../../services/http/tour/get_user_tours.dart';
import '../../../services/http/tour/pick_nearest_tour.dart';
import '../../../services/http/tour/is_valid_plan.dart';
import '../../../services/http/user/fetch_my_info.dart';

class PlanViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? currentUsername;
  Map<String, dynamic>? nearestPlan;

  /// 여행 목록을 불러오고, 가장 가까운 여행을 선택
  Future<void> fetchPlans(BuildContext context) async {
    try {
      // 1. 사용자 이름 불러오기
      final userInfo = await FetchMyInfo(context: context);
      currentUsername = userInfo['username'];

      // 2. 사용자 관련 여행 목록 불러오기
      final userPlans = await GetUserTours(context: context, username: currentUsername!);

      // 3. 유효한 여행만 필터링 (만료 or 코스 없는 여행 삭제)
      final validPlans = await FilterValidTours(context: context, plans: userPlans);

      // 4. 가장 가까운 여행 선택
      if (validPlans.isNotEmpty) {
        nearestPlan = PickNearestTour(validPlans: validPlans);
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

Future<List<dynamic>> FilterValidTours({
  required BuildContext context,
  required List<dynamic> plans,
}) async {
  final validPlans = <dynamic>[];

  for (final plan in plans) {
    final isValid = await IsValidPlan(context: context, plan: plan);
    if (isValid) {
      validPlans.add(plan);
    }
  }
  return validPlans;
}