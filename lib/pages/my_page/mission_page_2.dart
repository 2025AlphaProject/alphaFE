import 'dart:io';

import 'package:alpha_fe/components/camera.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar.dart';

class MissionPage_2 extends StatelessWidget {
  final String content;
  final bool isCompleted;

  const MissionPage_2({
    Key? key,
    required this.content,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: "미션 앱바 영역"),
      backgroundColor: Colors.white,
      body: MissionPage_2_body(content: content, isCompleted: isCompleted),
    );
  }
}

class MissionPage_2_body extends StatefulWidget {
  final String content;
  final bool isCompleted;

  const MissionPage_2_body({
    super.key,
    required this.content,
    required this.isCompleted,
  });


  @override
  State<MissionPage_2_body> createState() => _MissionPage_2_bodyState();
}

class _MissionPage_2_bodyState extends State<MissionPage_2_body> {
  final CameraService _cameraService = CameraService();
  File? _image;

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
              children: [
                Icon(
                  widget.isCompleted ? Icons.check_circle : Icons.cancel,
                  color: widget.isCompleted ? const Color(0xFF008000) : const Color(0xFFFF0000),
                  size: width * 0.06,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  widget.isCompleted ? "성공한 미션" : "미완료",
                  style: TextStyle(fontSize: width * 0.045),
                ),
              ],
            ),

            SizedBox(height: width * 0.05),

            // ✅ 미션 설명
            Text(
              widget.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.043,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: height * 0.023),

            // ✅ 사진 미리보기
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
              SizedBox(height: height * 0.046),
              ElevatedButton.icon(
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
            ] else ...[
              SizedBox(height: height * 0.036),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final File? image = await _cameraService.getImageFromCamera();
                      if (image != null) {
                        setState(() {
                          _image = image;
                        });
                      }
                    },
                    child: Text("재촬영", style: TextStyle(fontSize: width * 0.04)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.013,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
                  ),
                  SizedBox(width: width * 0.08),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 미션 성공 여부 처리
                    },
                    child: Text("미션 시행", style: TextStyle(fontSize: width * 0.04)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.013,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.025),
                      ),
                    ),
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