import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DateDropdown extends StatelessWidget {
  final List<String> dates;
  final ValueNotifier<String?> selectedDate;
  final double width;
  final double height;
  final void Function(String?)? onChanged;

  const DateDropdown({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.width,
    required this.height,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: const Text(
          "날짜 선택",
          style: TextStyle(
            fontSize: 16.5,
            color: Colors.black54,
          ),
        ),
        items: dates.map((date) => DropdownMenuItem<String>(
          value: date,
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16.5,
            ),
          ),
        )).toList(),
        value: selectedDate.value,
        onChanged: (value) {
          selectedDate.value = value;
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        buttonStyleData: ButtonStyleData(
          height: height * 0.06,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: width * 0.033),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
            color: Colors.grey[100],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          offset: Offset(0, 0),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: height * 0.055,
          padding: EdgeInsets.symmetric(horizontal: width * 0.033),
        ),
      ),
    );
  }
}