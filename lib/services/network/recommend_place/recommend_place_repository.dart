import 'dart:math';
import 'package:alpha_fe/services/network/recommend_place/recommend_place.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RecommendPlaceRepository {
  Future<(WebSocketChannel?, int?, String)> createRecommendationChannel(BuildContext context) async {
    final userId = await RecommendPlaceService.fetchUserId(context);
    if (userId == null) return (null, null, '');

    final randomDistrict = RecommendPlaceService.getRandomDistrict();
    final uniqueCode = Random().nextInt(1 << 31);
    final channel = RecommendPlaceService.openRecommendationChannel(
      userId: userId,
      district: randomDistrict,
      uniqueCode: uniqueCode,
    );

    return (channel, userId, randomDistrict);
  }
}