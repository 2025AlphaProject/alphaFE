import 'package:alpha_fe/pages/loading_page/loading_page2/view/loading_page2_view.dart';
import 'package:flutter/material.dart';

class LoadingPage2 extends StatefulWidget {
  const LoadingPage2({super.key});

  @override
  State<LoadingPage2> createState() => _LoadingPage2State();
}

class _LoadingPage2State extends State<LoadingPage2> {
  final List<bool> visibleList = [false, false, false];

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  Future<void> startAnimation() async {
    for (int i = 0; i < visibleList.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        visibleList[i] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingPage2View(visibleList: visibleList);
  }
}