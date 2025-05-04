import 'dart:io';
import 'package:alpha_fe/components/camera.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import 'package:alpha_fe/pages/my_page/mission_page_3.dart';

class MissionPage_2 extends StatelessWidget {
  final mission;

  const MissionPage_2({
    Key? key,
    required this.mission
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "미션 수행"),
      backgroundColor: Colors.white,
      body: MissionPage_2_body(mission:mission),
    );
  }
}

class MissionPage_2_body extends StatefulWidget {
  final mission;

  const MissionPage_2_body({
    super.key,
    required this.mission,
  });


  @override
  State<MissionPage_2_body> createState() => _MissionPage_2_bodyState();
}

class _MissionPage_2_bodyState extends State<MissionPage_2_body> {
  final CameraService _cameraService = CameraService();
  File? _image;
  // 체크박스 상태 변수 - 미션 선택용
  int _selectedPoseIndex = 1;
  int? _selectedMissionId = 1;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.023),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ 미션 상태 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.mission['isCompleted'] ? Icons.check_circle : Icons.cancel,
                  color: widget.mission['isCompleted'] ? const Color(0xFF008000) : const Color(0xFFFF0000),
                  size: width * 0.06,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  widget.mission['isCompleted']? "성공한 미션" : "미완료",
                  style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: width * 0.05),

            // ✅ 미션 장소
            if (!widget.mission['isCompleted'])
              Column(
                children: [
                  Text(
                    widget.mission['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.023),
                ],
              ),


            // ✅ 사진 미리보기 - 찍은 사진보기
            if (_image != null)
              Container(
                height: height * 0.32,
                width: width * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),

            if (_image == null) ...[
              widget.mission['image_url'].toString().isNotEmpty
                  ? Column( //장소 예시사진 있는 경우
                children: [
                  Image.network(
                    widget.mission['image_url'],
                    height: width * 0.53,
                    width: width * 0.8,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: width * 0.02),
                  Text(
                    "이 사진처럼 촬영해 보세요!",
                    style: TextStyle(
                      fontSize: width * 0.043,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
                  : Column( //장소 예시 사진이 없는 경우
                children: [
                  Icon(Icons.camera_alt, size: width * 0.2, color: Colors.grey),
                  SizedBox(height: width * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ //미션 선택하기 - 3가지 나열
                      RadioListTile<int>(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.black,
                        title: Text(
                          "브이 포즈로 사진을 찍어보세요",
                          style: TextStyle(
                            fontSize: width * 0.043,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 1,
                        groupValue: _selectedPoseIndex,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPoseIndex = value ?? -1;
                            _selectedMissionId = value; // Store selected value
                          });
                        },
                      ),
                      RadioListTile<int>(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.black,
                        title: Text(
                          "손가락 하트를 하고 사진을 찍어보세요",
                          style: TextStyle(
                            fontSize: width * 0.043,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 2,
                        groupValue: _selectedPoseIndex,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPoseIndex = value ?? -1;
                            _selectedMissionId = value; // Store selected value
                          });
                        },
                      ),
                      RadioListTile<int>(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.black,
                        title: Text(
                          "여러분이 사진에 꼭 등장해야 해요!",
                          style: TextStyle(
                            fontSize: width * 0.043,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: 3,
                        groupValue: _selectedPoseIndex,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPoseIndex = value ?? -1;
                            _selectedMissionId = value; // Store selected value
                          });
                        },
                      ),
                    ],
                  ),
                                  ],
              ),
              SizedBox(height: height * 0.046),
              ElevatedButton.icon( //찍은 사진이 없는 경우 사진 촬영버튼 나타남
                onPressed: () async {
                  final File? image = await _cameraService.getImageFromCamera();
                  if (image != null) {
                    setState(() {
                      _image = image;
                    });
                  }
                },
                icon: Icon(Icons.camera_alt, size: width * 0.06),
                label: Text(
                  "사진 촬영",
                  style: TextStyle(fontSize: width * 0.045),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.025),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.08,
                    vertical: height * 0.016,
                  ),
                  elevation: 2,
                ),
              ),
            ] else ...[ //찍은 사진이 있는 경우 -  재촬영버튼, 미션수행 버튼 띄우기
              SizedBox(height: height * 0.036),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton( //사진 재촬영버튼
                    onPressed: () async {
                      final File? image = await _cameraService.getImageFromCamera();
                      if (image != null) {
                        setState(() {
                          _image = image;
                        });
                      }
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
                    child: Text("재촬영", style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: width * 0.08),
                  ElevatedButton( //미션 수행 버튼
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFFF9F9F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          insetPadding: EdgeInsets.all(24),
                          title: const Text(
                            "미션을 진행하시겠습니까?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "이 사진으로 미션을 진행하게 됩니다.",
                            style: TextStyle(fontSize: 15),
                          ),
                          actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                setState(() {
                                  widget.mission['mission_id'] = _selectedMissionId;
                                });
                                Navigator.of(context).pop();
                                if (_selectedMissionId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => missionTest(
                                        mission: widget.mission,
                                        image: _image!,
                                      ),
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
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
                    child: Text("사진 업로드", style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}