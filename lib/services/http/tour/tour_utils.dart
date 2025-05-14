class TourUtils {
  static Map<String, dynamic> pickNearestTour(List<dynamic> validPlans) {
    validPlans.sort((a, b) {
      final aStart = DateTime.parse(a['start_date']);
      final bStart = DateTime.parse(b['start_date']);
      return aStart.difference(DateTime.now()).abs().compareTo(
        bStart.difference(DateTime.now()).abs(),
      );
    });

    final nearest = validPlans.first;
    return {
      'id': nearest['id'],
      'title': nearest['tour_name'] ?? '제목 없음',
      'start_date': nearest['start_date'] ?? '',
      'end_date': nearest['end_date'] ?? '',
    };
  }
}