import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: LoadingPage2(),
  ));
}

class LoadingPage2 extends StatefulWidget {
  const LoadingPage2({super.key});

  @override
  State<LoadingPage2> createState() => _LoadingPage2State();
}

class _LoadingPage2State extends State<LoadingPage2> {
  List<bool> _visibleList = [false, false, false];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < _visibleList.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _visibleList[i] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'CON',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          shadows: const [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 2,
                              color: Colors.black26,
                            )
                          ],
                        ),
                      ),
                      const TextSpan(
                        text: 'EVER?',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 2,
                              color: Colors.black26,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedIconText(
                    index: 0,
                    iconPath: 'assets/loading2_1.png',
                    text: 'AI 추천 여행 경로 생성',
                    width: width,
                    height: height,
                  ),
                  SizedBox(height: height * 0.0246),
                  _buildAnimatedIconText(
                    index: 1,
                    iconPath: 'assets/loading2_2.png',
                    text: '여행지 별 사진 미션 진행',
                    width: width,
                    height: height,
                  ),
                  SizedBox(height: height * 0.0246),
                  _buildAnimatedIconText(
                    index: 2,
                    iconPath: 'assets/loading2_3.png',
                    text: '일정 및 주변행사 모아보기',
                    width: width,
                    height: height,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIconText({
    required int index,
    required String iconPath,
    required String text,
    required double width,
    required double height,
  }) {
    return AnimatedOpacity(
      opacity: _visibleList[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconPath, width: 82.2),
          SizedBox(height: height * 0.018),
          Text(
            text,
            style: const TextStyle(
              fontSize: 22.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}