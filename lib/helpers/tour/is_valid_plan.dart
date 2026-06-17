import '../../services/http/tour/delete_tour_by_id.dart';
import '../../services/http/tour/fetch_tour_courses.dart';
import 'has_no_course.dart';
import 'is_tour_expired.dart';

Future<bool> isValidPlan({
  required Map<String, dynamic> plan,
}) async {
  final id = plan['id'];
  final expired = isTourExpired(plan['end_date']);

  try {
    final courseData = await fetchTourCourses(id);
    final empty = hasNoCourse(courseData);

    if (expired || empty) {
      await deleteTourById(id);
      return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}