// lib/app/controllers/input/gyro_input.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroInput extends GetxController {
  /// Horizontal tilt → left stick X (racing) atau right stick X (FPS)
  final tilt  = 0.0.obs; // event.y → kanan/kiri
  /// Vertical tilt → right stick Y (FPS aim up/down)
  final tiltY = 0.0.obs; // event.x → atas/bawah

  final sensitivity = 1.0.obs;

  double _prevX = 0.0;
  double _prevY = 0.0;

  static const double _alpha = 0.15; // low-pass Flutter-side
  // Catatan: Rust juga punya smoothing sendiri, tapi ini untuk reduce raw jitter

  StreamSubscription<AccelerometerEvent>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = accelerometerEventStream().listen((e) {
      // Horizontal
      final rawX = (e.y * sensitivity.value).clamp(-1.0, 1.0);
      final smoothX = _prevX + _alpha * (rawX - _prevX);
      _prevX = smoothX;
      tilt.value = smoothX;

      // Vertical (inverted: tilt maju = aim atas)
      final rawY = (-e.x * sensitivity.value).clamp(-1.0, 1.0);
      final smoothY = _prevY + _alpha * (rawY - _prevY);
      _prevY = smoothY;
      tiltY.value = smoothY;
    });
  }

  void setSensitivity(double v) => sensitivity.value = v;

  /// Reset ke nol — dipanggil saat mode berubah atau gyro dimatikan
  void reset() {
    _prevX = 0.0;
    _prevY = 0.0;
    tilt.value  = 0.0;
    tiltY.value = 0.0;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}