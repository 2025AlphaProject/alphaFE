class TourInfo {
  final int userId;
  final DateTime startDate;
  final DateTime endDate;

  TourInfo({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  factory TourInfo.fromJson(Map<String, dynamic> json, int userId) {
    return TourInfo(
      userId: userId,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  int get numberOfDays => endDate.difference(startDate).inDays + 1;

  List<String> get dateRange {
    final List<String> range = [];
    for (DateTime date = startDate;
    !date.isAfter(endDate);
    date = date.add(const Duration(days: 1))) {
      range.add(date.toIso8601String().substring(0, 10));
    }
    return range;
  }
}