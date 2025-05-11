import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingPage2View extends StatelessWidget {
  final List<bool> visibleList;

  const LoadingPage2View({super.key, required this.visibleList});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) width = 430;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildTitle(),
              SizedBox(height: height * 0.1),
              ...List.generate(3, (i) => Column(
                children: [
                  _buildAnimatedIconText(
                    index: i,
                    iconPath: 'assets/loading2_${i + 1}.png',
                    text: [
                      'AI 추천 여행 경로 생성',
                      '여행지 별 사진 미션 진행',
                      '일정 및 주변행사 모아보기',
                    ][i],
                    width: width,
                    height: height,
                  ),
                  SizedBox(height: height * 0.0246),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() => Center(
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
                Shadow(offset: Offset(2, 2), blurRadius: 2, color: Colors.black26)
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
                Shadow(offset: Offset(2, 2), blurRadius: 2, color: Colors.black26)
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAnimatedIconText({
    required int index,
    required String iconPath,
    required String text,
    required double width,
    required double height,
  }) {
    return AnimatedOpacity(
      opacity: visibleList[index] ? 1.0 : 0.0,
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