import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../viewModel/mission_page_1_viewModel.dart';
import '../../mission_success_page.dart';
import '../../mission_page_2/mission_page_2.dart';


Widget missionItem(BuildContext context, int index,) {
  final vm = context.watch<MissionPage1Viewmodel>();
  final mission = vm.getMissionByIndex(index);
  final bool isCompleted = mission?['isCompleted'] ?? false;
  final height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  if (kIsWeb) {
    width = 430;
  }

  return Padding(
    padding: EdgeInsets.symmetric(vertical: height * 0.01),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width * 0.95,
      ),
      child: GestureDetector(
        onTap: () {
          if (mission?['isCompleted'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissionSuccessPage(
                  tdp_id: mission?['tdp_id'],
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MissionPage_2(index: index),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0,0),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.018),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      color: isCompleted ? const Color(0xFF008000) : const Color(0xFFFF0000),
                      size: 24.6,
                    ),
                    SizedBox(width: width * 0.02),
                    SizedBox(//미션 관련 장소명
                      width: width * 0.65,
                      child: Text(
                        "${mission?['name']}",
                        style: const TextStyle(
                          fontSize: 20.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.08, top: height * 0.004),
                  child: Text( //미션 내용
                    (mission?['image_url']?.toString().isNotEmpty ?? false)
                        ? "• 예시 사진과 유사하게 촬영하기"  //사진 O
                        : "• 원하는 미션을 골라보세요",     //사진 X
                    style: const TextStyle(fontSize: 16.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}