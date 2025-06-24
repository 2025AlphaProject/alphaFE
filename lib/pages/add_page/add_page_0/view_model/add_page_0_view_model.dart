import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/pages/add_page/add_page_1/add_page_1.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/add_page_2.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/tour_create_view_model.dart';

class AddPage0ViewModel with ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  DateTimeRange? selectedDateRange;

  bool validateInputValuesOnly() {
    final title = titleController.text.trim();
    return title.isNotEmpty && title.length <= 10 && selectedDateRange != null;
  }

  bool isValidDateRange(DateTimeRange range) {
    return range.duration.inDays <= 2;
  }

  void updateSelectedDateRange(DateTimeRange range) {
    selectedDateRange = range;
    notifyListeners();
  }

  bool createTour({
    required BuildContext context,
    required String? sigun,
  }) {
    if (!validateInputValuesOnly()) return false;

    final title = titleController.text;
    final dateRange = selectedDateRange!;

    context.read<TourCreateViewModel>().registerTour(
      context,
      title,
      dateRange,
      onSuccess: (tourId) {
        if (sigun != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage_2(
                title: sigun,
                tourId: tourId,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage_1(
                tourId: tourId,
              ),
            ),
          );
        }
      },
    );
    return true;
  }

  void resetState() {
    titleController.clear();
    selectedDateRange = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}