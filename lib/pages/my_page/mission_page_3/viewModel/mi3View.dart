import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../components/app_bar.dart';
import 'package:alpha_fe/pages/my_page/mission_loading_page.dart';
import '../../mission_page_1/viewModel/mission_page_1_viewModel.dart';
import '../../mission_page_2/viewModel/mission_page_2_viewModel.dart';
import 'mission_page_3_viewModel.dart';

class missionTest extends StatefulWidget {
  final int index;
  const missionTest({super.key,required this.index});

  @override
  State<missionTest> createState() => _missionTestState();
}

class _missionTestState extends State<missionTest> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MissionPage3Viewmodel>(context).initialize(context, widget.index);
    });
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final vm1 = context.watch<MissionPage1Viewmodel>();
    final vm2 = context.watch<MissionPage2Viewmodel>();
    final vm = context.watch<MissionPage1Viewmodel>();
    final mission = vm1.getMissionByIndex(widget.index);
    final File? _image = vm2.image;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "미션 진행도"),
      body: vm.isLoading
          ? const MissionLoadingView()
          : Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.034),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (mission?['isCompleted']) ...[
                          const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          SizedBox(width: width * 0.009),
                          const Text(
                            "미션 성공!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                        if (!(mission?['isCompleted'])) ...[ //실패시
                          const Icon(Icons.cancel, color: Colors.red, size: 30),
                          SizedBox(width: width * 0.009),
                          const Text(
                            "미션 실패!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.009),
                  Text(
                    (mission?['image_url']?.toString().isNotEmpty ?? false)
                        ? "• 예시 사진과 유사하게 촬영하기"
                        : (mission?['mission_id'] == 1
                            ? "브이 포즈로 사진을 찍어보세요"
                            : (mission?['mission_id'] == 2
                                ? "손가락 하트를 하고 사진을 찍어보세요"
                                : '여러분이 사진에 꼭 등장해야 해요!')),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.036),
                  Container(
                    width: width * 0.72,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image != null
                        ? Image.file(_image, fit: BoxFit.cover)
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              '사진이 없습니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                  ),

                  SizedBox(height: height * 0.0577,),
                ],
              ),
            )
    );
  }
}
