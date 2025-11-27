import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroController extends GetxController with GetSingleTickerProviderStateMixin {
  RxDouble accelY = 0.0.obs;
  RxDouble sensitivity = 1.0.obs;
  var showSettings = false.obs;

  late AnimationController settingsAnim;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void onInit() {
    super.onInit();

    // Gyro
    _accelSub = accelerometerEventStream().listen((event) {
      accelY.value = event.y;
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
