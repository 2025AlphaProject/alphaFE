import 'package:flutter/material.dart';
import '../../dio/authorized_dio.dart';

Future<bool> IsValidPlan({
  required BuildContext context,
  required Map<String, dynamic> plan,
}) async {
  final dio = await getAuthorizedDio(context);
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
