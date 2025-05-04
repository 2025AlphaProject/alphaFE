import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String contentText;
  final VoidCallback? onConfirm;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.contentText,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: const Color(0xFFF9F9F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: width * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Text(
        contentText,
        style: TextStyle(
          fontSize: width * 0.04,
          color: Colors.black,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: width * 0.04,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}