import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../components/appbars/default_appbar/default_appbar.dart';
import 'package:alpha_fe/components/plan_edit.dart';
import 'package:alpha_fe/components/plan_course_event.dart';
import 'package:alpha_fe/pages/plan_page/add_user/add_user.dart';
import 'package:alpha_fe/pages/plan_page/plan_loading_page.dart';
import 'dashed_line.dart';
import 'traveler_list_view.dart';
import 'plan_info_view.dart';
import '../viewModel/plan_page_2_viewModel.dart';


class PlanPage2 extends StatefulWidget {
  const PlanPage2({Key? key}) : super(key: key);

  @override
  State<PlanPage2> createState() => _PlanPage2State();
}

class _PlanPage2State extends State<PlanPage2> {
  void _onDataRefreshed() {
    print('Data refreshed in PlanPage2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "나의 계획"),
      body: plan_page2_body(
      ),
    );
  }
}

class plan_page2_body extends StatefulWidget {
  const plan_page2_body({super.key});

  @override
  State<plan_page2_body> createState() => _plan_page2_bodyState();
}

class _plan_page2_bodyState extends State<plan_page2_body> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanPage2ViewModel>();

    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    return WillPopScope(
      onWillPop: () async => true,
      child: vm.isLoading
          ? const PlanLoadingView() // 로딩 중일 때 표시
          : Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: RefreshIndicator(
                onRefresh: () => vm.refreshData(context),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PlanInfo()
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: width * 0.07),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => Center(
                                  child: SizedBox(
                                    width: kIsWeb ? width * 0.95 : null,
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: const Color(0xFFF5F5F5),
                                      elevation: 10,
                                      contentPadding: EdgeInsets.zero,
                                      content: TravelEditMenu(
                                        startDate: vm.startDate,
                                        endDate: vm.endDate,
                                        tour_id: vm.tourId,
                                        tourName: vm.tourName,
                                        onRefresh: () => vm.refreshData(context),
                                        accessToken: vm.accessToken ?? "",
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              if (result == true) {
                                await vm.refreshData(context);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.005),
                      const travelerList(), // 여행자 목록 뷰
                      SizedBox(height: height * 0.02),
                      const DashedLine(),
                      travel_plan(
                        tour_id: vm.tourId,
                        courseData: vm.courseData,
                        onRefresh: () => vm.refreshData(context),
                        accessToken: vm.accessToken ?? "",
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
