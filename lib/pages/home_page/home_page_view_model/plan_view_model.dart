import 'package:alpha_fe/services/dio/authorized_dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../services/access_token/get_access_token_from_refresh_token.dart';
import '../../../services/http/tour/fetch_all_tours.dart';
import '../../../services/http/tour/is_valid_plan.dart';
import '../../../services/http/user/fetch_my_info.dart';

class PlanViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? currentUsername;
  Map<String, dynamic>? nearestPlan;
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
    final isValid = await isValidPlan(context: context, plan: plan);
    if (isValid) {
      validPlans.add(plan);
    }
  }
  return validPlans;
}

Map<String, dynamic> PickNearestTour({
  required List<dynamic> validPlans,
}) {
  validPlans.sort((a, b) {
    final aStart = DateTime.parse(a['start_date']);
    final bStart = DateTime.parse(b['start_date']);
    return aStart.difference(DateTime.now()).abs().compareTo(
      bStart.difference(DateTime.now()).abs(),
    );
  });

  final nearest = validPlans.first;
  return {
    'id': nearest['id'],
    'title': nearest['tour_name'] ?? '제목 없음',
    'start_date': nearest['start_date'] ?? '',
    'end_date': nearest['end_date'] ?? '',
  };
}

List<dynamic> filterToursByUsername(List<dynamic> allTours, String username) {
  return allTours.where((plan) {
    final users = plan['user'] ?? [];
    return users.any((u) => u['username'] == username);
  }).toList();
}

Future<List<dynamic>> GetUserTours({
  required BuildContext context,
  required String username,
}) async {
  final allTours = await fetchAllTours(context);
  return filterToursByUsername(allTours, username);
}

bool isTourExpired(String endDateStr) {
  final endDate = DateTime.tryParse(endDateStr.replaceAll('.', '-'));
  if (endDate == null) return true;
  return DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
}

bool hasNoCourse(List<dynamic> courseData) {
  return courseData.every((entry) =>
  (entry['places'] is List) && (entry['places'] as List).isEmpty);
}

Future<bool> isValidPlan({
  required BuildContext context,
  required Map<String, dynamic> plan,
}) async {
  final id = plan['id'].toString();
  final expired = isTourExpired(plan['end_date']);

  try {
    final courseData = await fetchTourCourses(context, id);
    final empty = hasNoCourse(courseData);

    if (expired || empty) {
      await deleteTourById(context, id);
      return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}