import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../components/appbars/search_appbar/search_appbar_view.dart';
import '../../components/proceed_button.dart';
import '../../controllers/home_page_controller.dart';
import '../../controllers/recommended_place_controller.dart';
import 'widgets/greeting_header.dart';
import 'widgets/upcoming_plan_section.dart';
import 'widgets/trending_place_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homePageController = Get.find<HomePageController>();
  final recommendPlaceController = Get.find<RecommendedPlaceController>();
  @override
  void initState() {
    super.initState();
    recommendPlaceController.fetchRecommendation();  // 페이지 접근 할 때 마다 랜덤 장소 생성
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: homePageController.isLoading.value
            ? const Center(child: CircularProgressIndicator())  // TODO: 정보를 불러오는 중입니다! 페이지 필요하다면?
            : Stack(
          children: [
            Positioned.fill(
              top: height * 0.1,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: homePageController.scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.066,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.024),
                            GreetingHeader(
                              username:
                              homePageController.username.value,
                            ),
                            SizedBox(height: height * 0.024),
                            UpcomingPlanSection(
                              isLoading:
                              homePageController.isLoading.value,
                              nearestPlan:
                              homePageController.nearestPlan.value,
                              width: width,
                              height: height,
                            ),
                            SizedBox(height: height * 0.06),
                            Center(
                              child: Obx(() =>
                                recommendPlaceController.isLoading.value
                                  ? ProceedButton(
                                  size_w: width * 0.586,
                                  size_h: height * 0.055,
                                  text: "정보를 불러오는 중입니다!",
                                  fontSize_: 15,
                                  fontWeight_: FontWeight.bold,
                                  onTap: () {
                                  },
                                )
                                  : ProceedButton(
                                  size_w: width * 0.586,
                                  size_h: height * 0.055,
                                  text: "✨ 새로운 장소 탐험하기",
                                  fontSize_: 15,
                                  fontWeight_: FontWeight.bold,
                                  onTap: () {
                                    homePageController.scrollToBottom();
                                  },
                                ),
                              )
                            ),
                            SizedBox(height: height * 0.11),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02),
                              child: const Text(
                                "오늘\n이런 곳은 어떤가요?",
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.04),
                            TrendingPlaceSection(
                              recommendedPlace:
                              recommendPlaceController
                                  .recommendedPlace.value,
                              sigunguText: recommendPlaceController
                                  .sigunguText.value,
                              username: homePageController
                                  .username.value,
                              width: width,
                              height: height,
                              onTap: () {
                                homePageController
                                    .handleTrendingPlaceTap();
                              },
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  homePageController.scrollToTop();
                                },
                                icon: Icon(
                                  Icons.arrow_drop_up,
                                  color: Colors.grey,
                                  size: width * 0.06,
                                ),
                                label: const Text(
                                  '홈으로 이동',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SearchAppBar(),
          ],
        ),
      ),
    ));
  }
}
