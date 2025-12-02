import 'package:get/get.dart';
import 'package:mobile_app/app/controllers/gyro_controller.dart';

import '../controllers/gyro_view_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GyroViewController>(
      () => GyroViewController(),
    );
    Get.lazyPut<GyroController>(() => GyroController());
  }
}
