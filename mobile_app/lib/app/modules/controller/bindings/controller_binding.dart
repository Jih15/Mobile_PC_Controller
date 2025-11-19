import 'package:get/get.dart';

import '../controllers/controller_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ControllerController>(
      () => ControllerController(),
    );
  }
}
