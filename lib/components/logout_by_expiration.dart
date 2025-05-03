import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> LogoutByExpiration(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('자동 로그아웃'),
        content: const Text('오랜 시간 사용하지 않아 자동으로 로그아웃되었습니다.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );

    const secureStorage = FlutterSecureStorage();

    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');

    if (!context.mounted) {
      return;
    }

    Phoenix.rebirth(context);
  }

void buildApp({required Widget home}) {
  runApp(
    MaterialApp(
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}