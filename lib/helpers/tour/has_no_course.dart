bool hasNoCourse(List<dynamic> courseData) {
  return courseData.every((entry) =>
  (entry['places'] is List) && (entry['places'] as List).isEmpty);
}