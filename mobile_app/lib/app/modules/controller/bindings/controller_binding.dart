import 'package:get/get.dart';

import '../controllers/gyro_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GyroController>(
      () => GyroController(),
    );
  }
}
