import 'dart:async';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/gyro_input.dart';
import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/rblb_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';

import 'package:mobile_app/app/data/models/input_event.dart';
import 'package:mobile_app/app/services/websocket_service.dart';

class InputController extends GetxController {
  final gyro = Get.find<GyroInput>();
  final analog = Get.find<AnalogInput>();
  final rblb = Get.find<RBLBInput>();
  final gamepad = Get.find<GamepadInput>();

  Timer? _sendLoop;

  static const _tick = Duration(milliseconds: 16); // ~60Hz

  @override
  void onInit() {
    super.onInit();

    _sendLoop = Timer.periodic(_tick, (_) => _send());
  }

  void _send() {
    final event = InputEvent.combined(
      steering: gyro.tilt.value,
      throttle: rblb.throttle,
      brake: rblb.brake,
      buttons: gamepad.buttons,
      sticks: {
        "left": {
          "x": analog.leftX.value,
          "y": analog.leftY.value,
        },
        "right": {
          "x": analog.rightX.value,
          "y": analog.rightY.value,
        },
      },
    );

    WebSocketService.to.send(event.toJson());
  }

  @override
  void onClose() {
    _sendLoop?.cancel();
    super.onClose();
  }
}
