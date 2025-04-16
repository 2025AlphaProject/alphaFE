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
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ 상태 표시
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

            SizedBox(height: width * 0.1),

            // ✅ 촬영 버튼
            if (!widget.isCompleted) //미완료 미션일 경우만 사진 촬영버튼 나타나도록
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 카메라 촬영 기능 연결 예정
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
                    vertical: width * 0.035,
                  ),
                  elevation: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}