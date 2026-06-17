import 'package:flutter/material.dart';

class TravelAnimation extends ChangeNotifier {
  late List<AnimationController> controllers;
  final List<Animation<double>> animations = [];
  List<double> animationProgress = [0, 0, 0];
  int currentTextIndex = 0;

  void setup(TickerProvider vsync) {
    controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: vsync,
        duration: const Duration(seconds: 1),
      );
    });

    for (var controller in controllers) {
      animations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
      );
    }

    startSequentialAnimation(0);
  }

  void startSequentialAnimation(int index) {
    if (index >= controllers.length) return;

    controllers[index].forward().then((_) {
      animationProgress[index] = 1.0;
      currentTextIndex = index + 1;
      notifyListeners();
      startSequentialAnimation(index + 1);
    });

    controllers[index].addListener(() {
      animationProgress[index] = animations[index].value;
      notifyListeners();
    });
  }

  void disposeControllers() {
    for (var controller in controllers) {
      controller.dispose();
    }
  }
}
