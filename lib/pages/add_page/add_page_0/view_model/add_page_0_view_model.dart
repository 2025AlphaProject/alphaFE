import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:alpha_fe/pages/add_page/add_page_1/add_page_1.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/add_page_2.dart';
import 'package:alpha_fe/components/custom_alert_dialog.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/tour_create_view_model.dart';

class AddPage0ViewModel with ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  DateTimeRange? selectedDateRange;

  bool validateInput(BuildContext context) {
    final title = titleController.text.trim();
    print('title: "$title", length: ${title.length}');
    print('selectedDateRange: $selectedDateRange');

    if (title.isEmpty || title.length > 10 || selectedDateRange == null) {
      showDialog(
        context: context,
        builder: (context) => const CustomAlertDialog(
          title: '입력 오류',
          contentText: '여행 이름(10자 이내)과 날짜를 모두 입력해주세요',
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: const Locale('ko', 'KR'),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.light,
            dialogTheme: const DialogTheme(
              backgroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C2C2C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              secondary: Color(0xFFFFF176),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2C2C2C),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.duration.inDays > 2) {
        await showDialog(
          context: context,
          builder: (context) => const CustomAlertDialog(
            title: '안내',
            contentText: '최대 3일까지 선택할 수 있습니다.',
          ),
        );
        return;
      }

      selectedDateRange = picked;
      notifyListeners();
    }
  }

  void createTour(
      BuildContext context,
      String? sigun,
      ) {
    if (!validateInput(context)) return;

    final title = titleController.text;
    final dateRange = selectedDateRange!;
    final accessToken = context.read<AuthProvider>().accessToken;

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
                accessToken: accessToken,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage_1(
                tourId: tourId,
                accessToken: accessToken,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}