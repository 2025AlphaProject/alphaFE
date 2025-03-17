import 'package:flutter/material.dart';

class ConnectionPageExample extends StatelessWidget {
  const ConnectionPageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('연결 페이지 예제입니다')),
      body: const Center(
        child: Text('연결 페이지 예제입니다', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
