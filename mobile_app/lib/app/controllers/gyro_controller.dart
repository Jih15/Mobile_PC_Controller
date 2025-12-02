import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile_app/app/data/models/input_event.dart';
import 'package:mobile_app/app/services/websocket_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroController extends GetxController{
  RxDouble tilt = 0.0.obs;
  RxDouble sensitivity = 1.0.obs;

  // Smoothing 
  double _previous = 0.0;
  final double alpha = 0.15;

  StreamSubscription<AccelerometerEvent>? _tiltStream;

  @override
  void onInit() {
    _tiltStream = accelerometerEventStream().listen((event) {
      double raw = event.y;

      // Apply Sensitivity
      double mapped = (raw * sensitivity.value).clamp(-1.0, 1.0);

      // Apply Smoothing
      double smooth = _previous + alpha * (mapped - _previous);
      _previous = smooth;

      tilt.value = smooth;

      WebSocketService.to.send(InputEvent.gyro(smooth).toJson());

    });
    super.onInit();
  }

  void setSensitivity(double value){
    sensitivity.value = value;
  }

  @override
  void onClose() {
    _tiltStream?.cancel();
    super.onClose();
  }
}