import 'package:flutter/material.dart';

//미션 성공 여부 로딩페이지 띄우기
class MissionLoadingView extends StatelessWidget {
  const MissionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "미션 성공 여부를\n판단하고 있습니다!\n잠시만 기다려주세요",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.064,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.024),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.133),
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
