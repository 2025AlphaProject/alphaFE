import 'package:flutter/material.dart';

import '../../../helpers/tour/filter_valid_tour.dart';
import '../../../helpers/tour/get_user_tours.dart';
import '../../../helpers/tour/pick_nearest_tour.dart';
import '../../../services/http/user/fetch_my_info.dart';

class PlanViewModel extends ChangeNotifier {
  bool isLoading = true;
  String? currentUsername;
  Map<String, dynamic>? nearestPlan;
  Future<void> fetchPlans(BuildContext context) async {
    final userInfo = await FetchMyInfo();
    currentUsername = userInfo['username'];
    final userPlans = await getUserTours(username: currentUsername!);
    final validPlans = await filterValidTours(plans: userPlans);
    if (validPlans.isNotEmpty) {
      nearestPlan = pickNearestTour(validPlans: validPlans);
    } else {
      nearestPlan = null;
    }
    isLoading = false;
    notifyListeners(); // 상태 변경 알림
  }
}