import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile_app/app/utils/constant.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService extends GetxService {
  static WebSocketService get to => Get.find<WebSocketService>();

  WebSocketChannel? _channel;

  final isConnected = false.obs;

  Future<WebSocketService> init() async {
    await connect();
    return this;
  }

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri(
          scheme: 'ws',
          host: AppConfig.baseUrl,
          port: AppConfig.port,
        ),
      );

      isConnected.value = true;

      _channel!.stream.listen(
        (msg) {
          print("WS recv: $msg");
        },
        onDone: () => isConnected.value = false,
        onError: (e) {
          isConnected.value = false;
          print("WS error: $e");
        },
      );

    } catch (e) {
      isConnected.value = false;
      print("WS connect error: $e");
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel == null) return;
    final jsonData = jsonEncode(data);
    _channel!.sink.add(jsonData);
  }

  void disconnect() {
    _channel?.sink.close();
    isConnected.value = false;
  }
}
