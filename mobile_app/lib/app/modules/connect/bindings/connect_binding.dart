import 'package:get/get.dart';
import 'package:mobile_app/app/controllers/gyro_controller.dart';
import 'package:mobile_app/app/controllers/input_controller.dart';
import 'package:mobile_app/app/controllers/streaming_controller.dart';

import '../controllers/connect_controller.dart';

class ConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectController>(() => ConnectController());
    Get.put(StreamingController());
    Get.put(InputController());
    Get.put(GyroController());
  }
}
