import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/services/websocket_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroViewController extends GetxController with GetSingleTickerProviderStateMixin {
  RxDouble accelY = 0.0.obs;
  RxDouble sensitivity = 1.0.obs;
  var showSettings = false.obs;

  late AnimationController settingsAnim;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;

  final tiltValue = 0.0.obs;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void onInit() {
    super.onInit();

    // Gyro
    _accelSub = accelerometerEventStream().listen((event) {
      // Mapping dengan sensitivity
      double mapped = (event.y * sensitivity.value).clamp(-1.0, 1.0);

      tiltValue.value = mapped;

      // Kirim ke PC
      WebSocketService.to.sendGyro(mapped);
    });


    // Settings Animation
    settingsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    scaleAnim = CurvedAnimation(
      parent: settingsAnim,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuad
    );

    opacityAnim = CurvedAnimation(
      parent: settingsAnim,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn
    );
  }

  void onGyroUpdate(double raw){
    double mapped = raw.clamp(-1.0, 1.0);

    tiltValue.value = mapped;

    WebSocketService.to.sendGyro(mapped);
  }

  void showSettingsPopUp(){
    showSettings.value = true;
    settingsAnim.forward(from: 0);
  }

  void hideSettingsPopUp() async{
    await settingsAnim.reverse();
    showSettings.value = false;
  }

  void toggleSettings(){
    // showSettings.value = !showSettings.value;
    if (showSettings.value) {
      hideSettingsPopUp();
    } else {
      showSettingsPopUp();
    }
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
