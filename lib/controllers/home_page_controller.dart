import 'package:alpha_fe/services/http/user/fetch_my_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/add_page/add_page_0/add_page_0.dart';

class HomePageController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxMap<String, dynamic> recommendedPlace = <String, dynamic>{}.obs;
  RxMap<String, dynamic> nearestPlan = <String, dynamic>{}.obs;
  Rx<String> username = "".obs;
  Rx<bool> isLoading = false.obs;
  Rx<String> sigunguText = "".obs;
  Rx<String> currentUsername = "".obs;

  void changeSigunguText(String address) async {
    final address  = recommendedPlace.value['address'] as String;
    if (address.split(" ").length > 1) {
      sigunguText.value = address.split(" ")[1];
    } else {
      sigunguText.value = "";
    }
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

  }

 @override
 void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}