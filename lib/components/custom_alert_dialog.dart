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

    return AlertDialog(
      backgroundColor: const Color(0xFFF9F9F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Text(
        contentText,
        style: const TextStyle(
          fontSize: 18.5,
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
            textStyle: const TextStyle(
              fontSize: 16.5,
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