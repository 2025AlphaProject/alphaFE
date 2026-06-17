import 'package:alpha_fe/pages/loading_page/loading_page1/travel_path/travel_animation.dart';
import 'package:alpha_fe/pages/loading_page/loading_page1/view/loading_page1_view.dart';
import 'package:flutter/material.dart';

class LoadingPage1 extends StatelessWidget {
  const LoadingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingPage1Body(),
    );
  }
}

class LoadingPage1Body extends StatefulWidget {
  const LoadingPage1Body({super.key});

  @override
  State<LoadingPage1Body> createState() => _LoadingPage1Body();
}

class _LoadingPage1Body extends State<LoadingPage1Body>
    with TickerProviderStateMixin {
  late final List<AnimationController> controllers = [];
  final List<Animation<double>> animations = [];
  final List<double> animationProgress = [0, 0, 0];
  int currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      animation.addListener(() {
        setState(() {
          animationProgress[i] = animation.value;
        });
      });
      controllers.add(controller);
      animations.add(animation);
    }
    _startSequentialAnimation(0);
  }

  void _startSequentialAnimation(int index) {
    if (index >= controllers.length) return;
    controllers[index].forward().then((_) {
      setState(() {
        animationProgress[index] = 1.0;
        currentTextIndex = index + 1;
      });
      _startSequentialAnimation(index + 1);
    });
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingPage1View(
      animationProgress: animationProgress,
      currentTextIndex: currentTextIndex,
    );
  }
}