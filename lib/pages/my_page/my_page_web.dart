import 'package:flutter/material.dart';
import 'package:alpha_fe/components/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPage_Web extends StatelessWidget {
  const MyPage_Web({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
                width: 150,
              ),
            ),
            SizedBox(height: height * 0.2),
            const Text(
              '이 기능은 앱에서만 지원됩니다.',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.15),
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse('https://drive.google.com/file/d/1gHgo81jTxybE8JcQ6nYdhIUGThPBE89W/view?usp=sharing'));
              },
              child: const Text(
                '앱 다운로드',
                style: TextStyle(
                  fontSize: 20,
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
