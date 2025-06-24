import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/add_page_0.dart';
import 'plan_view_model.dart';
import 'recommend_place_view_model.dart';
import 'package:provider/provider.dart';

class HomePageViewModel extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  /// 최초 진입 시 사용자 이름, 여행 계획, 추천 장소를 요청
  void initialize(BuildContext context) {
    context.read<PlanViewModel>().fetchPlans(context);
    context.read<RecommendPlaceViewModel>().fetchRecommendation(context);
  }

  /// getter로 View에 제공
  Map<String, dynamic>? recommendedPlace(BuildContext context) =>
      context.read<RecommendPlaceViewModel>().recommendedPlace;
  Map<String, dynamic>? nearestPlan(BuildContext context) =>
      context.read<PlanViewModel>().nearestPlan;

  String? username(BuildContext context) =>
      context.read<PlanViewModel>().currentUsername;

  bool isLoading(BuildContext context) =>
      context.read<PlanViewModel>().isLoading;

  String sigunguText(BuildContext context) {
    final address = recommendedPlace(context)?['address'] ?? '';
    if (address is String && address.split(' ').length > 1) {
      return address.split(' ')[1];
    }
    return '';
  }

  /// 트렌딩 버튼 탭 시 AddPage_0으로 이동
  void handleTrendingPlaceTap(BuildContext context, String? accessToken) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => AddPage_0(
          sigun: sigunguText(context),
        ),
      ),
    );
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
