import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketListener {
  static const String defaultWsUrl = 'wss://strings-api.onrender.com/ws';
  final String wsUrl;
  WebSocketChannel? _channel;

  WebSocketListener({this.wsUrl = defaultWsUrl});

  Stream<dynamic>? connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      return _channel!.stream.map((event) => jsonDecode(event));
    } catch (e) {
      return null;
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
