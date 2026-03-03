// lib/app/controllers/input/gamepad_input.dart

import 'package:get/get.dart';

class GamepadInput extends GetxController {
  final buttons = <String, bool>{}.obs;

  void press(String key)            => buttons[key] = true;
  void release(String key)          => buttons[key] = false;
  void set(String key, bool pressed) => buttons[key] = pressed;

  void reset() => buttons.clear();
}