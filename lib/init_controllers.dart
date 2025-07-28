import 'package:get/get.dart';

import 'controllers/home_page_controller.dart';
import 'controllers/recommended_place_controller.dart';

void initControllers() {
  Get.put(HomePageController());
  Get.put(RecommendedPlaceController());
}