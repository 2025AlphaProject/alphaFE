import 'package:alpha_fe/pages/my_page/mission_page_3/mission_page_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/pages/my_page/mission_page_2/viewModel/mission_page_2_viewModel.dart';
import '../../mission_page_1/viewModel/mission_page_1_viewModel.dart';

class MissionTestButton extends StatelessWidget {
  final int index;
  const MissionTestButton({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MissionPage2Viewmodel(),
      child: _MissionTestButtonInner(index: index),
    );
  }
}

class _MissionTestButtonInner extends StatefulWidget {
  final int index;
  const _MissionTestButtonInner({Key? key, required this.index}) : super(key: key);

  @override
  State<_MissionTestButtonInner> createState() => _MissionTestButtonInnerState();
}

class _MissionTestButtonInnerState extends State<_MissionTestButtonInner> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    final vm = context.watch<MissionPage1Viewmodel>();
    final vm2 = context.watch<MissionPage2Viewmodel>();
    final mission = vm.getMissionByIndex(widget.index);
    return ElevatedButton( //미션 수행 버튼
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF9F9F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: width * .0583, vertical: height * .027),
            title: const Text(
              "미션을 진행하시겠습니까?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "이 사진으로 미션을 진행하게 됩니다.",
              style: TextStyle(fontSize: 15),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.0243, vertical: height * 0.005),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("취소", style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (mission != null && vm2.selectedMissionId != null) {
                    mission['mission_id'] = vm2.selectedMissionId;
                  }
                  Navigator.of(context).pop();
                  if (vm2.selectedMissionId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => missionTest(index: widget.index),
                      ),
                    );
                  }
                },
                child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.07,
          vertical: height * 0.013,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text("사진 업로드", style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
    );
  }
}