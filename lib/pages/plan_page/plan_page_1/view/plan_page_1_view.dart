import 'package:alpha_fe/pages/plan_page/plan_page_1/view/travel_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/appbars/default_appbar/default_appbar.dart';
import '../viewModel/plan_sort_viewModel.dart';

class PlanPage_1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "나의 계획"),
      body: PlanPage_1_Body(),
    );
  }
}

class PlanPage_1_Body extends StatefulWidget {
  const PlanPage_1_Body({super.key});

  @override
  State<PlanPage_1_Body> createState() => _PlanPage_1_BodyState();
}

class _PlanPage_1_BodyState extends State<PlanPage_1_Body> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SortViewModel>();
    final plans = vm.sortedCardData;

    return vm.isLoading
        ? const Center(child: CircularProgressIndicator())
        : plans.isEmpty
            ? EmptyPlan() //여행 없는 경우
            : PlanList(); //여행 있는 경우
  }
}
