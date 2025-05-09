import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SaveLoadingView extends StatefulWidget {
  const SaveLoadingView({Key? key}) : super(key: key);

  @override
  State<SaveLoadingView> createState() => _SaveLoadingViewState();
}

class _SaveLoadingViewState extends State<SaveLoadingView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .085, vertical: height * .0391),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '여행 경로 저장중...\n잠시만 기다려주세요',
              style: TextStyle(fontSize: 22.6, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: height * 0.029),
            const Center(
              child: LinearProgressIndicator(
                value: null,
                minHeight: 8,
                backgroundColor: Color(0xFFE0E0E0), // light gray
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}