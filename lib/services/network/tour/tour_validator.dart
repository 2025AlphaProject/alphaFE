import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

class TourValidator {
  static Future<List<dynamic>> filterValidTours(BuildContext context, List<dynamic> plans) async {
    final dio = await getAuthorizedDio(context);
    final validPlans = <dynamic>[];

    for (final plan in plans) {
      final isValid = await _isValidPlan(plan, dio);
      if (isValid) {
        validPlans.add(plan);
      }
    }
    return validPlans;
  }

  static Future<bool> _isValidPlan(Map<String, dynamic> plan, Dio dio) async {
    final id = plan['id'].toString();
    final endDate = DateTime.tryParse(plan['end_date'].replaceAll('.', '-'));
    final isExpired = endDate != null &&
        DateTime.now().isAfter(endDate.add(const Duration(days: 1)));

    try {
      final response = await dio.get('http://conever.duckdns.org:8000/tour/course/$id/');
      final data = response.data;
      final hasNoCourse = (data is List) && data.every((entry) {
        return (entry['places'] is List) && (entry['places'] as List).isEmpty;
      });

      if (hasNoCourse || isExpired) {
        await dio.delete('http://conever.duckdns.org:8000/tour/$id/');
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
