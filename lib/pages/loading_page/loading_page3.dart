import 'package:alpha_fe/components/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingPage3 extends StatelessWidget {
  final String? kakaoNativeAppKey;
  final String? kakaoJavaScriptAppKey;

  const LoadingPage3({super.key, required this.kakaoNativeAppKey, required this.kakaoJavaScriptAppKey});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.064),
          child: Column(
            children: [
              SizedBox(height: height * 0.0394),
              // Centered logo
              Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: width * 0.8,
                ),
              ),
              SizedBox(height: height * 0.0591),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '지금,\n',
                      style: TextStyle(
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: '커네버',
                      style: TextStyle(
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '에서\n',
                      style: TextStyle(
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: '시작',
                      style: TextStyle(
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '하기',
                      style: TextStyle(
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Kakao login button at the bottom
              Padding(
                padding: EdgeInsets.fromLTRB(width*0.0533, 0, width*0.0533, height*0.0394),
                child: GestureDetector(
                  onTap: () {
                    KakaoLoginService.login(
                      context,
                      kakaoNativeAppKey: kakaoNativeAppKey!,
                      kakaoJavaScriptAppKey: kakaoJavaScriptAppKey!,
                    );
                  },
                  child: Image.asset(
                    'assets/kakao_login_button.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}