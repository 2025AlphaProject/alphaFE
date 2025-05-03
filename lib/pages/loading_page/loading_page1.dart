import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const LoadingPage1());
}

class LoadingPage1 extends StatelessWidget {
  const LoadingPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TravelAnimationScreen(),
    );
  }
}

class TravelAnimationScreen extends StatefulWidget {
  @override
  _TravelAnimationScreenState createState() => _TravelAnimationScreenState();
}

class _TravelAnimationScreenState extends State<TravelAnimationScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  List<double> _animationProgress = [0, 0, 0]; // 각 구간의 진행률 저장
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startSequentialAnimation(0); // 첫 번째 애니메이션 시작
  }

  void _startSequentialAnimation(int index) {
    if (index >= _controllers.length) return;

    _controllers[index].forward().then((_) {
      setState(() {
        _animationProgress[index] = 1.0; // 현재 구간 애니메이션 완료
        _currentTextIndex = index + 1;
      });
      _startSequentialAnimation(index + 1); // 다음 구간 애니메이션 실행
    });

    _controllers[index].addListener(() {
      setState(() {
        _animationProgress[index] = _animations[index].value;
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: height*0.4,
            child: Padding(
              padding: EdgeInsets.fromLTRB(width*0.0533, height*0.246, width*0.0533, 0),
              child: Center(
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: _currentTextIndex >= 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          "어디로 떠날지가 고민이시나요?",
                          style: TextStyle(fontSize: width*0.064, fontWeight: FontWeight.bold),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _currentTextIndex >= 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          "AI가 추천하는 일정을 확인하고,",
                          style: TextStyle(fontSize: width*0.064, fontWeight: FontWeight.bold),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _currentTextIndex >= 2 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          "가장 특별한 여행을 떠나보세요!",
                          style: TextStyle(fontSize: width*0.064, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          SizedBox(
            height: height*0.4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      heightFactor: 1.0,
                      child: Image.asset(
                        'assets/seoul_image.jpg',
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: TravelPathPainter(_animationProgress),
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TravelPathPainter extends CustomPainter {
  final List<double> progress;
  TravelPathPainter(this.progress);

  final Paint pathPaint = Paint()
    ..color = const Color(0xFFFF9500)
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    List<Offset> points = [
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.75),
      Offset(size.width * 0.4, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.3),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      Path segment = Path()..moveTo(points[i].dx, points[i].dy);

      Offset midPoint = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );

      double offset = 50; // 곡선 굴곡 정도
      if (i == 0) {
        midPoint = Offset(midPoint.dx, midPoint.dy + offset);
      } else if (i == 1 || i == 2) {
        midPoint = Offset(midPoint.dx, midPoint.dy - offset);
      } else {
        midPoint = Offset(midPoint.dx, midPoint.dy + offset);
      }

      segment.quadraticBezierTo(midPoint.dx, midPoint.dy, points[i + 1].dx, points[i + 1].dy);

      // 점선 효과 적용
      PathMetrics pathMetrics = segment.computeMetrics();
      for (PathMetric pathMetric in pathMetrics) {
        Path extractPath = pathMetric.extractPath(0, pathMetric.length * progress[i]);

        // 점선 스타일 적용
        Path dashedPath = Path();
        double dashLength = 10.0; // 점선 길이
        double gapLength = 5.0; // 점선 간격
        double distance = 0.0;

        for (var metric in extractPath.computeMetrics()) {
          while (distance < metric.length) {
            double nextDistance = distance + dashLength;
            dashedPath.addPath(
              metric.extractPath(distance, nextDistance),
              Offset.zero,
            );
            distance = nextDistance + gapLength;
          }
        }

        canvas.drawPath(dashedPath, pathPaint);
      }
    }

    // 여행 경로 점 표시
    for (Offset point in points) {
      canvas.drawCircle(point, 8.0, Paint()..color = const Color(0xFFFF3B30));
    }
  }

  @override
  bool shouldRepaint(TravelPathPainter oldDelegate) => true;
}
