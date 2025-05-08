import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'loading_page1.dart';
import 'loading_page2.dart';
import 'loading_page3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LoginPageController extends StatefulWidget {
  final String? kakaoNativeAppKey;
  final String? kakaoJavaScriptAppKey;
  const LoginPageController({Key? key, required this.kakaoNativeAppKey, required this.kakaoJavaScriptAppKey}) : super(key: key);

  @override
  State<LoginPageController> createState() => _LoginPageControllerState();
}

class _LoginPageControllerState extends State<LoginPageController> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
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
                  kakaoJavaScriptAppKey: widget.kakaoJavaScriptAppKey,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.029),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: WormEffect(
                dotHeight: height * 0.012,
                dotWidth: width * 0.026,
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