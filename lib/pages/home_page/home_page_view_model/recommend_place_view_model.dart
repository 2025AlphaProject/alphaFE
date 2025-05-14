import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../services/network/recommend_place/recommend_place.dart';
import '../../../services/network/recommend_place/recommend_place_repository.dart';

class RecommendPlaceViewModel extends ChangeNotifier {
  Map<String, dynamic>? recommendedPlace;
  bool isLoading = false;

  Future<void> fetchRecommendation(BuildContext context, {int retryCount = 0}) async {
    isLoading = true;
    notifyListeners();

    final repo = RecommendPlaceRepository();
    final (channel, userId, district) = await repo.createRecommendationChannel(context);

    if (channel == null) {
      _showErrorDialog(context);
      isLoading = false;
      notifyListeners();
      return;
    }

    channel.stream.listen((message) async {
      final data = jsonDecode(message);

      if (data['status'] != 'SUCCESS') return;

      dynamic result = data['result'];
      if (result is String) result = jsonDecode(result);

      final places = result.expand((course) => course is List ? course : []).toList();
      final filtered = places.where((p) => p['image1'] != null && p['image1'] is String && (p['image1'] as String).isNotEmpty).toList();

      if (filtered.isEmpty) return;

      final selected = filtered[Random().nextInt(filtered.length)];
      selected['image1'] = RecommendPlaceService.formatImageUrl(selected['image1']);

      recommendedPlace = selected;
      isLoading = false;
      notifyListeners();
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("트렌딩 장소 오류"),
        content: Text("추천 장소를 가져오는 데 실패했습니다."),
      ),
    );
  }
}