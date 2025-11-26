import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroController extends GetxController {
  RxDouble accelY = 0.0.obs;
  RxDouble sensitivity = 1.0.obs;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void onInit() {
    super.onInit();

    _accelSub = accelerometerEventStream().listen((event) {
      accelY.value = event.y; 
    });
  }

  void setSensitivity(double value) {
    sensitivity.value = value;
  }

  @override
  void onClose() {
    _accelSub?.cancel();
    super.onClose();
  }
}
