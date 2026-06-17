import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../mission_page_1/viewModel/mission_page_1_viewModel.dart';
import '../../mission_page_2/viewmodel/mission_page_2_viewmodel.dart';
import 'mission_test_button.dart';


// ✅ 사진 미리보기 - 찍은 사진보기
class MissionPreviewImage extends StatelessWidget {
  final File image;

  const MissionPreviewImage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    // ✅ 사진 미리보기 - 찍은 사진보기
    return Container(
      height: height * 0.32,
      width: width * 0.7,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Image.file(image, fit: BoxFit.cover),
    );
  }
}

class PlaceImage extends StatelessWidget {
  final int index;
  const PlaceImage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    final vm = context.watch<MissionPage1Viewmodel>();
    final mission = vm.getMissionByIndex(index);

    return Column(
      children: [
        Image.network(
          mission?['image_url'],
          height: height * 0.53,
          width: width * 0.8,
          fit: BoxFit.cover,
        ),
        SizedBox(height: width * 0.02),
        const Text(
          "이 사진처럼 촬영해 보세요!",
          style: TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        // Wrap MissionTestButton with ChangeNotifierProvider for MissionPage2Viewmodel
        ChangeNotifierProvider(
          create: (_) => MissionPage2Viewmodel(),
          child: MissionTestButton(index: 1,),  //TODO: index 숫자 바꾸기
        ),
      ],
    );
  }
}

class PoseImage extends StatelessWidget {
  const PoseImage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    final vm = context.watch<MissionPage1Viewmodel>();
    final vm2 = context.watch<MissionPage2Viewmodel>();
    return Column(
      children: [
        const Icon(Icons.camera_alt, size: 82.2, color: Colors.grey),
        SizedBox(height: height * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<int>(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.black,
              title: const Text(
                "브이 포즈로 사진을 찍어보세요",
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: 1,
              groupValue: vm2.selectedPoseIndex,
              onChanged: (int? value) {
                if (value != null) {
                  vm2.selectPose(value);
                }
              },
            ),
            RadioListTile<int>(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.black,
              title: const Text(
                "손가락 하트를 하고 사진을 찍어보세요",
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: 2,
              groupValue: vm2.selectedPoseIndex,
              onChanged: (int? value) {
                if (value != null) {
                  vm2.selectPose(value);
                }
              },
            ),
            RadioListTile<int>(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.black,
              title: const Text(
                "여러분이 사진에 꼭 등장해야 해요!",
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: 3,
              groupValue: vm2.selectedPoseIndex,
              onChanged: (int? value) {
                if (value != null) {
                  vm2.selectPose(value);
                }
              },
            ),
          ],
        )
      ],
    );
  }
}


