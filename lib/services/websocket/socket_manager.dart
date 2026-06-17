import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static WebSocketChannel? _channel;

  static WebSocketChannel connect(String uri) {
    close(); // 기존 연결 종료
    _channel = WebSocketChannel.connect(Uri.parse(uri));
    return _channel!;
  }

  static WebSocketChannel? get channel => _channel;

  static void close() {
    _channel?.sink.close();
    _channel = null;
  }

  static void send(String data) {
    _channel?.sink.add(data);
  }
}