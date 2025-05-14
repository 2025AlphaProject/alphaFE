import 'dart:math';
import 'package:alpha_fe/services/network/recommend_place/recommend_place.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:alpha_fe/services/websocket/socket_manager.dart';

class RecommendPlaceRepository {
  Future<(WebSocketChannel?, int?, String)> createRecommendationChannel(BuildContext context) async {
    final userId = await RecommendPlaceService.fetchUserId(context);
    if (userId == null) return (null, null, '');

    final randomDistrict = RecommendPlaceService.getRandomDistrict();
    final uniqueCode = Random().nextInt(1 << 31);

    final uri =
        'ws://conever.duckdns.org:8000/tour/recommend/?user_id=$userId&areaCode=1&sigunguName=$randomDistrict&unique_code=$uniqueCode&days=1';

    final channel = WebSocketManager.connect(uri);
    return (channel, userId, randomDistrict);
  }
}