import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showExitDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text("트렌딩 장소 오류"),
      content: const Text("추천 장소를 가져오는 데 실패했습니다."),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("확인"),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}