import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/tour/filter_valid_tour.dart';
import '../helpers/tour/get_user_tours.dart';
import '../helpers/tour/pick_nearest_tour.dart';
import '../pages/add_page/add_page_0/add_page_0.dart';
import '../services/http/user/fetch_my_info.dart';

class HomePageController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxMap<String, dynamic> nearestPlan = <String, dynamic>{}.obs;
  Rx<String> username = "".obs;
  Rx<bool> isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  void handleTrendingPlaceTap() {
    Get.to(() => const AddPage_0());
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    final userInfo = await FetchMyInfo();
    username.value = userInfo['username'];
    final userPlans = await getUserTours(username: username.value);
    final validPlans = await filterValidTours(plans: userPlans);
    if (validPlans.isNotEmpty) {
      nearestPlan.value = pickNearestTour(validPlans: validPlans);
    }
    isLoading.value = false;
  }

 @override
 void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}