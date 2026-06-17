import 'package:flutter/material.dart';
import '../../../../components/date_dropdown.dart';

class DateSelector extends StatelessWidget {
  final List<String> dates;
  final ValueNotifier<String?> selectedDate;
  final double height;
  final double width;
  final void Function(String?) onChanged;

  const DateSelector({
    required this.dates,
    required this.selectedDate,
    required this.height,
    required this.width,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateDropdown(
      selectedDate: selectedDate,
      dates: dates,
      height: height,
      width: width,
      onChanged: onChanged,
    );
  }
}