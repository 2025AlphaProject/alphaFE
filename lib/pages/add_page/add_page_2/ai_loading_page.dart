import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AILoadingView extends StatelessWidget {
  const AILoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AI 가 경로를\n생성중 입니다!\n잠시만 기다려주세요",
              style: TextStyle(
                fontSize: 26.7,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.024),
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
