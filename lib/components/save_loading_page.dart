import 'package:flutter/material.dart';

class SaveLoadingView extends StatelessWidget {
  const SaveLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "경로를 저장 중...\n잠시만 기다려주세요",
              style: TextStyle(
                fontSize: width * 0.064,
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
