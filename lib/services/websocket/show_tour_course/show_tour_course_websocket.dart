import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

class ShowTourCourseWebsocket {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  void connect({
    required int userId,
    required String areaName,
    required int days,
    required Function(dynamic data) onData,
    required Function onError,
  }) {
    final uniqueCode = Random().nextInt(1 << 31);
    final wsUrl =
        'ws://conever.duckdns.org:80/tour/recommend/?user_id=$userId&areaCode=1&sigunguName=$areaName&unique_code=$uniqueCode&days=$days';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _subscription = _channel!.stream.listen(
          (message) {
        final data = jsonDecode(message);
        onData(data);
      },
      onError: (_) => onError(),
      cancelOnError: true,
    );
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
  }
}