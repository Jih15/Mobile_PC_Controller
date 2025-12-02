import 'package:get/get.dart';

import '../controllers/gyro_view_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GyroViewController>(
      () => GyroViewController(),
    );
  }
}
