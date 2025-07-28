import 'dart:convert';
import 'dart:math';

import 'package:alpha_fe/helpers/tour/extract_sigungu_text.dart';
import 'package:get/get.dart';

import '../services/websocket/recommend_place/recommend_place.dart';
import '../services/websocket/recommend_place/recommend_place_repository.dart';

class RecommendedPlaceController extends GetxController {
  RxMap<String, dynamic> recommendedPlace = <String, dynamic>{}.obs;
  Rx<bool> isLoading = false.obs;
  Rx<String> sigunguText = ''.obs;

  Future<void> fetchRecommendation({int retryCount = 0}) async {
    isLoading.value = true;

    final repo = RecommendPlaceRepository();
    final (channel, userId, district) = await repo.createRecommendationChannel();

    if (channel == null) {
      // TODO: Error Dialog
      isLoading.value = false;
      return;
    }

    channel.stream.listen((message) async {
      final data = jsonDecode(message);

      if (data['status'] != 'SUCCESS') {
        return;
      }

      dynamic result = data['result'];
      if (result is String) {
        result = jsonDecode(result);
      }

      final places = result.expand((course) => course is List ? course : []).toList();

      final filtered = places.where((p) =>
      p['image1'] != null &&
          p['image1'] is String &&
          (p['image1'] as String).isNotEmpty).toList();

      if (filtered.isEmpty) return;

      final selected = filtered[Random().nextInt(filtered.length)];
      selected['image1'] = RecommendPlaceService.formatImageUrl(selected['image1']);

      recommendedPlace.value = selected;

      sigunguText.value = extractSigunguText(recommendedPlace.value);
      isLoading.value = false;
    });
  }
}