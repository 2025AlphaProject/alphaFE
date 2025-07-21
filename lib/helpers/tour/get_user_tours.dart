import '../../services/http/tour/fetch_all_tours.dart';
import 'filter_tours_by_username.dart';

Future<List<dynamic>> getUserTours({
  required String username,
}) async {
  final allTours = await fetchAllTours();
  return filterToursByUsername(allTours, username);
}