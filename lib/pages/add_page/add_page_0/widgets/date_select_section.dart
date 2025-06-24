import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/add_page_0_view_model.dart';


class DateSelectSection extends StatelessWidget {
  final double width;
  final double height;
  final AddPage0ViewModel viewModel;

  const DateSelectSection({
    super.key,
    required this.width,
    required this.height,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✏️ 여행 날짜",
          style: TextStyle(
            fontSize: 20.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: height * 0.01),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: height * 0.06,
                child: TextField(
                  readOnly: true,
                  cursorColor: const Color(0xFF2C2C2C),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: viewModel.selectedDateRange == null
                        ? ""
                        : "${viewModel.selectedDateRange!.start.year}.${viewModel.selectedDateRange!.start.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.start.day.toString().padLeft(2, '0')} ~ "
                        "${viewModel.selectedDateRange!.end.year}.${viewModel.selectedDateRange!.end.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.end.day.toString().padLeft(2, '0')}",
                    hintStyle: const TextStyle(
                      fontSize: 12.3,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.03,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
            DateSelectButton(
              height: height * 0.058,
              width: width * 0.14,
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('ko', 'KR'),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2C2C2C),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  if (!viewModel.isValidDateRange(picked)) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('입력 오류'),
                        content: Text('지금은 3일 이내로만 선택할 수 있습니다'),
                      ),
                    );
                    return;
                  }

                  viewModel.updateSelectedDateRange(picked);
                }
              },
            ),
          ],
        ),
        SizedBox(height: height * 0.005),
        Text(
          "• 지금은 3일만 선택할 수 있습니다",
          style: TextStyle(
            fontSize: 12.3,
            color: Colors.red.shade500,
          ),
        ),
      ],
    );
  }
}


class DateSelectButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onPressed;

  const DateSelectButton({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "🗓️",
          style: TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}