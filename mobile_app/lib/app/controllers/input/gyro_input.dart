import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroInput extends GetxController {
  final tilt = 0.0.obs;
  final sensitivity = 1.0.obs;

  double _previous = 0.0;
  static const double alpha = 0.15;

  StreamSubscription<AccelerometerEvent>? _sub;

  @override
  void onInit() {
    super.onInit();

    _sub = accelerometerEventStream().listen((e) {
      final raw = e.y;
      final mapped = (raw * sensitivity.value).clamp(-1.0, 1.0);
      final smooth = _previous + alpha * (mapped - _previous);
      _previous = smooth;
      tilt.value = smooth;
    });
  }

  void setSensitivity(double v) {
    sensitivity.value = v;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
