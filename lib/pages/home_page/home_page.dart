import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../components/appbars/search_appbar/search_appbar_view.dart';
import '../../components/proceed_button.dart'; // 버튼 컴포넌트
import 'home_page_view_model/home_page_view_model.dart';
import 'widgets/greeting_header.dart';
import 'widgets/upcoming_plan_section.dart';
import 'widgets/trending_place_section.dart';
import '../../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomePageViewModel>().initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomePageViewModel>();
    final recommendedPlace = viewModel.recommendedPlace(context);
    final nearestPlan = viewModel.nearestPlan(context);
    final username = viewModel.username(context);
    final sigunguText = viewModel.sigunguText(context);
    final isLoading = viewModel.isLoading(context);
    final accessToken = context.read<AuthProvider>().accessToken;
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: height * 0.1,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: viewModel.scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.066,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.024),
                            GreetingHeader(username: username),
                            SizedBox(height: height * 0.024),
                            UpcomingPlanSection(
                              isLoading: isLoading,
                              nearestPlan: nearestPlan,
                              width: width,
                              height: height,
                              accessToken: accessToken,
                            ),
                            SizedBox(height: height * 0.06),
                            Center(
                              child: ProceedButton(
                                size_w: width * 0.586,
                                size_h: height * 0.055,
                                text: "✨ 새로운 장소 탐험하기",
                                fontSize_: 15,
                                fontWeight_: FontWeight.bold,
                                onTap: () {
                                  viewModel.scrollToBottom();
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.11),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
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
                              recommendedPlace: recommendedPlace,
                              sigunguText: sigunguText,
                              username: username,
                              width: width,
                              height: height,
                              accessToken: accessToken,
                              onTap: () {
                                viewModel.handleTrendingPlaceTap(context, accessToken);
                              },
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  viewModel.scrollToTop();
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
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            SearchAppBar(
            ),
          ],
        ),
      ),
    );
  }
}