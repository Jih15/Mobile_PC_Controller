import 'package:get/get.dart';
import 'package:mobile_app/app/data/models/input_event.dart';
import '../services/websocket_service.dart';

class ConnectionController extends GetxController {
  final ws = WebSocketService.to;

  void sendGyro(double value) {
    ws.send(InputEvent.gyro(value).toJson());
  }

  void sendThrottle(double value) {
    ws.send(InputEvent.throttle(value).toJson());
  }

  void sendBrake(double value) {
    ws.send(InputEvent.brake(value).toJson());
  }

  void sendJoystick(String stick, double x, double y) {
    ws.send(InputEvent.joystick(stick, x, y).toJson());
  }

  void sendButton(String key, bool pressed) {
    ws.send(InputEvent.button(key, pressed).toJson());
  }
}
