bool isTourExpired(String endDateStr) {
  final endDate = DateTime.tryParse(endDateStr.replaceAll('.', '-'));
  if (endDate == null) return true;
  return DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
}