import 'package:flutter/material.dart';
import 'package:alpha_fe/components/app_bar.dart';

class MyPage_Web extends StatelessWidget {
  const MyPage_Web({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: DefaultAppBar(title: '마이페이지'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icon.png',
                width: width * 0.15,
              ),
            ),
            SizedBox(height: width * 0.06),
            Text(
              '이 기능은 앱에서만 지원됩니다.',
              style: TextStyle(
                  fontSize: width * 0.02,
                  fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.035),
            TextButton(
              onPressed: () {
                // 여기에 다운로드 링크 연결
                // 예: launchUrl(Uri.parse('https://play.google.com/...'));
              },
              child: Text(
                '앱 다운로드',
                style: TextStyle(
                  fontSize: width * 0.015,
                  decoration: TextDecoration.underline,
                  color: Color(0xFF2684FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
