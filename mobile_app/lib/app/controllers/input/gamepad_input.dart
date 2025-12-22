import 'package:get/get.dart';

class GamepadInput extends GetxController {
  /// contoh key: "A", "B", "X", "Y", "LB", "RB", "START"
  final buttons = <String, bool>{}.obs;

  void press(String key) {
    buttons[key] = true;
  }

  void release(String key) {
    buttons[key] = false;
  }

  void set(String key, bool pressed) {
    buttons[key] = pressed;
  }
}
