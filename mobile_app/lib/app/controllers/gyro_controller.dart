import 'dart:async';

import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroController extends GetxController {
  RxDouble accelX = 0.0.obs;
  RxDouble accelY = 0.0.obs;
  RxDouble accelZ = 0.0.obs;

  var sensitivity = 1.0.obs;

  StreamSubscription<AccelerometerEvent>? _stream;

  @override
  void onInit() {
    _stream = accelerometerEventStream().listen((AccelerometerEvent event){
      accelX.value = event.x;
      accelY.value = event.y;
      accelZ.value = event.z;
    });
    super.onInit();
  }

  void setSensitivity(double value){
    sensitivity.value = value;
  }

  @override
  void onClose() {
    super.onClose();
    _stream?.cancel();
  }
}
