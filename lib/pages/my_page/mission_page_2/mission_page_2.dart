import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../components/app_bar.dart';
import '../mission_page_1/viewModel/mission_page_1_viewModel.dart';
import 'viewModel/mission_page_2_viewModel.dart';
import 'view/mission_image.dart';
import 'view/mission_test_button.dart';


class MissionPage_2 extends StatelessWidget {
  final int index;

  const MissionPage_2({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "미션 수행"),
      backgroundColor: Colors.white,
      body: MissionPage_2_body(index: index),
    );
  }
}

class MissionPage_2_body extends StatefulWidget {
  final int index;
  const MissionPage_2_body({super.key, required this.index});

  @override
  State<MissionPage_2_body> createState() => _MissionPage_2_bodyState();
}

class _MissionPage_2_bodyState extends State<MissionPage_2_body> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    final vm = context.watch<MissionPage1Viewmodel>();
    final mission = vm.getMissionByIndex(widget.index);
    final vm2 = context.watch<MissionPage2Viewmodel>();
    final File?_image = vm2.image;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.023),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 미션 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  mission?['isCompleted'] ? Icons.check_circle : Icons.cancel,
                  color: mission?['isCompleted'] ? const Color(0xFF008000) : const Color(0xFFFF0000),
                  size: 24.6,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  mission?['isCompleted']? "성공한 미션" : "미완료",
                  style: const TextStyle(fontSize: 20.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: width * 0.05),
            // ✅ 미션 장소
            if (!mission?['isCompleted'])
              Column(
                children: [
                  Text(
                    mission?['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.023),
                ],
              ),
            if (_image != null)
              MissionPreviewImage(
                image: _image,
              ),
            if (_image != null) ...[
              mission != null && mission['image_url'] != null && mission['image_url'].toString().isNotEmpty
                  ? PlaceImage(index: widget.index)
                  : PoseImage(),
              SizedBox(height: height * 0.046),
              // 사진 촬영 버튼
              ElevatedButton.icon(
                onPressed: () async {
                  final vm2R = context.read<MissionPage2Viewmodel>();
                  await vm2R.takePicture();
                },
                icon: const Icon(Icons.camera_alt, size: 24.6),
                label: const Text(
                  "사진 촬영",
                  style: TextStyle(fontSize: 18.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.08,
                    vertical: height * 0.016,
                  ),
                  elevation: 2,
                ),
              ),
            ] else ...[ //찍은 사진이 있는 경우 -  재촬영버튼, 미션수행 버튼 띄우기
              const SizedBox(height: 1),
              SizedBox(height: height * 0.036),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton( //재촬영버튼
                    onPressed: () async {
                      final vm2R = context.read<MissionPage2Viewmodel>();
                      await vm2R.takePicture();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9F9F9),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.013,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
                    child: const Text("재촬영", style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: width * 0.08),
                  MissionTestButton(index: widget.index)
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
