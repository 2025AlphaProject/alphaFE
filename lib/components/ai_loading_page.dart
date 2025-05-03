import 'package:flutter/material.dart';

class AILoadingView extends StatelessWidget {
  const AILoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "AI 가 경로를\n생성중 입니다!\n잠시만 기다려주세요",
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
