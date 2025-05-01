import 'package:flutter/material.dart';
import 'loading_page1.dart';
import 'loading_page2.dart';
import 'loading_page3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // pubspec.yaml에 추가 필요

void main() {
  runApp(
      const MaterialApp(
        home: LoginPageController(),
      ));
}

class LoginPageController extends StatefulWidget {
  final String? kakaoNativeAppKey;
  const LoginPageController({Key? key, this.kakaoNativeAppKey}) : super(key: key);

  @override
  State<LoginPageController> createState() => _LoginPageControllerState();
}

class _LoginPageControllerState extends State<LoginPageController> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: [
                const LoadingPage1(),
                const LoadingPage2(),
                LoadingPage3(
                  kakaoNativeAppKey: widget.kakaoNativeAppKey,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.black,
                dotColor: Colors.grey.shade300,
              ),
            ),
          )
        ],
      ),
    );
  }
}