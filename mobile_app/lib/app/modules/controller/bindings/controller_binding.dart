import 'package:get/get.dart';
import 'package:mobile_app/app/controllers/connection_controller.dart';
import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';
import 'package:mobile_app/app/controllers/input/gyro_input.dart';
import 'package:mobile_app/app/controllers/input/input_controller.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
// import 'package:mobile_app/app/controllers/gyro_controller.dart';

import '../controllers/controller_view_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GyroInput>(() => GyroInput());
    Get.lazyPut<AnalogInput>(() => AnalogInput());
    Get.lazyPut<TriggerInput>(() => TriggerInput());
    Get.lazyPut<GamepadInput>(() => GamepadInput());
    Get.lazyPut<InputController>(() => InputController());

    // Connection
    Get.lazyPut<ConnectionController>(() => ConnectionController());

    // View
    Get.lazyPut<ControllerViewController>(() => ControllerViewController());
  }
}
