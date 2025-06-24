import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

//페이지 인디케이터
class PlanPageIndicator extends StatefulWidget {
  final PageController controller;
  final int count;
  final double? dotSize;
  final double? dotActiveWidth;

  const PlanPageIndicator({
    Key? key,
    required this.controller,
    required this.count,
    this.dotSize,
    this.dotActiveWidth,
  }) : super(key: key);

  @override
  State<PlanPageIndicator> createState() => _PlanPageIndicatorState();
}

class _PlanPageIndicatorState extends State<PlanPageIndicator> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.initialPage;
    widget.controller.addListener(_pageListener);
  }

  void _pageListener() {
    final newPage = widget.controller.page?.round() ?? 0;
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final dotSize = widget.dotSize ?? width * 0.02;
    final dotActiveWidth = widget.dotActiveWidth ?? width * 0.03;
    if (kIsWeb) {
      width = 430;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: dotSize * 0.3),
          width: isActive ? dotActiveWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? Colors.black87 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(dotSize * 0.5),
          ),
        );
      }),
    );
  }
}