import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//미션 성공 여부 로딩페이지 띄우기
class MissionLoadingView extends StatelessWidget {
  const MissionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "미션 성공 여부를\n판단하고 있습니다!\n잠시만 기다려주세요",
              style: TextStyle(
                fontSize: 26.7,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.133),
              child: const LinearProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
