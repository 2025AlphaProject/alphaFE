import 'is_valid_plan.dart';

Future<List<dynamic>> filterValidTours({
  required List<dynamic> plans,
}) async {
  final validPlans = <dynamic>[];

  for (final plan in plans) {
    final isValid = await isValidPlan(plan: plan);
    if (isValid) {
      validPlans.add(plan);
    }
  }
  return validPlans;
}