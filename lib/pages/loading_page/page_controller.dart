import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_page1/loading_page1.dart';
import 'loading_page2/loading_page2.dart';
import 'loading_view.dart';
import 'loading_page3.dart';

class LoginPageController extends StatelessWidget {
  final String? kakaoNativeAppKey;
  final String? kakaoJavaScriptAppKey;

  const LoginPageController({
    super.key,
    required this.kakaoNativeAppKey,
    required this.kakaoJavaScriptAppKey,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoadingViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: viewModel.pageController,
              onPageChanged: viewModel.changePage,
              children: [
                const LoadingPage1(),
                const LoadingPage2(),
                LoadingPage3(
                  kakaoNativeAppKey: kakaoNativeAppKey,
                  kakaoJavaScriptAppKey: kakaoJavaScriptAppKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}