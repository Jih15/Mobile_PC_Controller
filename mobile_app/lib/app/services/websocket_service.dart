import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService extends GetxService {
  static WebSocketService get to => Get.find<WebSocketService>();

  IOWebSocketChannel? _channel;

  final isConnected = false.obs;
  final serverIp = "192.168.1.10".obs; // ubah sesuai IP PC

  Future<WebSocketService> init() async {
    connect();
    return this;
  }

  void connect() {
    try {
      print("🔌 Connecting to ws://${serverIp.value}:9002 ...");

      _channel = IOWebSocketChannel.connect(
        "ws://${serverIp.value}:9002",
      );

      isConnected.value = true;
      print("✅ Connected to WebSocket");

      _channel!.stream.listen(
        (data) {
          print("📩 Received: $data");
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          reconnect();
        },
        onDone: () {
          print("⚠️ WebSocket closed");
          reconnect();
        },
      );
    } catch (e) {
      print("❌ Connect Exception: $e");
      reconnect();
    }
  }

  void reconnect() async {
    if (isConnected.value == false) return;

    isConnected.value = false;
    print("🔁 Reconnecting in 2 seconds...");
    await Future.delayed(const Duration(seconds: 2));
    connect();
  }

  void send(dynamic jsonMap) {
    if (_channel == null || isConnected.value == false) {
      print("⚠️ WebSocket not connected, cannot send");
      return;
    }

    final encoded = jsonEncode(jsonMap);
    print("📤 Sending: $encoded");
    _channel!.sink.add(encoded);
  }

  // Event Sender

  void sendGyro(double value) {
    send({
      "type": "gyro",
      "value": value,
    });
  }

  void sendJoystick(double x, double y) {
    send({
      "type": "joystick",
      "x": x,
      "y": y,
    });
  }

  void sendButton(String key, bool pressed) {
    send({
      "type": "button",
      "key": key,
      "pressed": pressed,
    });
  }

  void sendThrottle(double value) {
    send({
      "type": "throttle",
      "value": value,
    });
  }

  void sendBrake(double value) {
    send({
      "type": "brake",
      "value": value,
    });
  }

  @override
  void onClose() {
    _channel?.sink.close(status.goingAway);
    super.onClose();
  }
}
