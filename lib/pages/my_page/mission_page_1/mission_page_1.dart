import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../components/app_bar.dart';
import 'viewModel/mission_page_1_viewModel.dart';
import 'view/mission_progress.dart';
import 'view/mission_item.dart';


class MissionPage1 extends StatefulWidget {
  final todayPlaces;
  const MissionPage1({super.key, required this.todayPlaces});

  @override
  State<MissionPage1> createState() => _mission1ViewState();
}

class _mission1ViewState extends State<MissionPage1> {
  @override
  void initState() {
    super.initState();
    // The initialization will be handled after the provider is available in build.
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MissionPage1Viewmodel>(
      create: (_) => MissionPage1Viewmodel(),
      child: Builder(
        builder: (context) {
          // Call initialize after provider is available.
          Future.microtask(() {
            Provider.of<MissionPage1Viewmodel>(context, listen: false).initialize(context, widget.todayPlaces);
          });
          final height = MediaQuery.of(context).size.height;
          double width = MediaQuery.of(context).size.width;
          if (kIsWeb) {
            width = 430;
          }
          final vm = context.watch<MissionPage1Viewmodel>();
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            appBar: const DefaultAppBar(title: "미션 진행도"),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 0.023),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.046),
                        MissionProgressIndicator(completed: vm.completed, total: vm.total),
                        SizedBox(height: height * 0.0461),
                        vm.missions.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: height * 0.1),
                                child: Column(
                                  children: [
                                    Text(
                                      '😯',
                                      style: TextStyle(
                                        fontSize: width * 0.1,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.02),
                                    Text(
                                      '현재 수행 가능한 미션이 없어요!',
                                      style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: vm.missions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  return missionItem(context, index);
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
